import SwiftUI
import PlaygroundSupport

//struct Couse :

enum LoadingState<Value> {
    case idle
    case loading
    case failed(String)
    case loaded(Value)
}

protocol LoadableObject: ObservableObject {
    associatedtype Output
    var state: LoadingState<Output> { get }
    func load()
}

class Resource: Identifiable {
    let numChildren : Int
    let title : String
    let type : String
    let url : String
    var parent : Resource?
    var children : [Resource]?
    
    var icon: String {
        if children == nil {
            return "doc"
        } else if children!.isEmpty {
            return "folder"
        } else {
            return "folder.fill"
        }
    }
    
    init(_ tuple: (title: String, numChildren: Int, type: String, url: String)) {
        self.numChildren = tuple.numChildren
        self.title = tuple.title
        self.type = tuple.type
        self.url = tuple.url
        
        children = self.type == "collection" ? [] : nil
    }
    
    fileprivate var treeIds : (parent: String, id: String) {
        var pathString = url.replacingOccurrences(of: "https://sakai.duke.edu/access/content/group/", with: "")
        if pathString.last! == "/" { pathString.removeLast() }
        var pathArray = pathString.split(separator: "/")
        pathArray.removeLast()
        
        return (parent: pathArray.joined(separator: "/"),
                id: pathString)
    }
}

class ResourceViewModel: LoadableObject {
    
    
    
//    typealias Output = [Resource]
//
//    enum State {
//        case idle
//        case loading
//        case failed(String)
//        case loaded([Resource])
//    }
    
    @Published private(set) var state: LoadingState<[Resource]> = .idle
    
    private let siteId: String
    //    private let loader: ArticleLoader
    
    //    init(articleID: Article.ID, loader: ArticleLoader) {
    //        self.articleID = articleID
    //        self.loader = loader
    //    }
    
    init(_ id: String) {
        self.siteId = id
    }
    
    func load() {
        state = .loading
        
        do {
            print("loading")
            guard let fileUrl = Bundle.main.url(forResource: "resources280", withExtension: "json"),
                  let jsonData = try String(contentsOf: fileUrl).data(using: .utf8),
                  let fullJson = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: AnyObject],
                  let json = fullJson["content_collection"] as? [[String: AnyObject]] else {
                print("json?")
                self.state = .failed("couldn't detach json")
                return
            }
            var resources = [Resource]()
            for resource in json {
                guard let numChildren = resource["numChildren"] as? Int,
                      let type = resource["type"] as? String,
                      let title = resource["title"] as? String,
                      let url = resource["url"] as? String else {
                    print("A RESOURCE WAS NIL!")
                    continue }
                resources.append(Resource((title, numChildren, type, url)))
            }
            for res in resources {
                print(res.title)
            }
            self.state = .loaded(resources)
        } catch {
            self.state = .failed(error.localizedDescription)
        }
    }
}




struct AsyncContentView<Source: LoadableObject, Content: View>: View {
    @ObservedObject var source: Source
    var content: (Source.Output) -> Content
    
    init(source: Source, @ViewBuilder content: @escaping (Source.Output) -> Content) {
        self.source = source
        self.content = content
    }
    
    
    var body: some View {
        switch source.state {
        case .idle:
            Color.clear.onAppear(perform: source.load)
        case .loading:
            ProgressView()
        case .failed(let error):
            Text(error)
            //            ErrorView(error: error, retryHandler: source.load)
        case .loaded(let output):
            content(output)
        }
    }
}


struct ContentView : View {
    @ObservedObject var viewModel = ResourceViewModel("stuff")
    
    var body: some View {
        ZStack {
            Color.blue
            AsyncContentView(source: viewModel) { resources in
                List(resources, children: \.children) { item in
                    Image(systemName: item.icon)
                    Text(item.title)
                }
            }
        }
        .frame(width: 300, height: 600)
        
    }
}

PlaygroundPage.current.setLiveView(ContentView())
