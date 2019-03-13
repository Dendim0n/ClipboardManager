import AppKit

// Custom menu supporting "search-as-you-type" based on https://github.com/mikekazakov/MGKMenuWithFilter.
class ClipboardMenu: NSMenu,NSMenuDelegate {
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    let headerItemView = FilterMenuItemView(frame: NSRect(x: 0, y: 0, width: 200, height: 200))
    let headerItem = NSMenuItem()
    init(title:Array<String>) {
        let titleStr = title.randomElement()!
        super.init(title: titleStr)
        headerItemView.title = titleStr
        headerItem.title = titleStr
        headerItem.view = headerItemView
        addItem(headerItem)
        self.delegate = self
    }
    override init(title: String) {
        super.init(title: title)
        headerItemView.title = title
        headerItem.title = title
        headerItem.view = headerItemView
        addItem(headerItem)
        self.delegate = self
    }
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        guard item is HistoryMenuItem else {
            return
        }
        if let content = (item as! HistoryMenuItem).content {
            switch content.contentType {
            case HistoryContentType.data.rawValue:
                if let data = content.data {
                    self.headerItemView.setPreview(content: data)
                }
                break
            case HistoryContentType.string.rawValue:
                if let str = content.string {
                    self.headerItemView.setPreview(content: str)
                }
                break
            default:
                break
            }
        }
    }
    func updateFilter(filter: String) {
        for item in items[1...(items.count - 1)] {
            item.isHidden = !validateItemWithFilter(item, filter)
        }
        
        if highlightedItem == nil || highlightedItem?.isHidden == true {
            var itemToHighlight: NSMenuItem?
            for item in items[1...(items.count - 1)] {
                if !item.isHidden && item.isEnabled {
                    itemToHighlight = item
                    break
                }
            }
            
            if itemToHighlight != nil {
                let highlightItemSelector = NSSelectorFromString("highlightItem:")
                perform(highlightItemSelector, with: itemToHighlight)
            }
        }
    }
    
    private func validateItemWithFilter(_ item: NSMenuItem, _ filter: String) -> Bool {
        if filter.isEmpty {
            return true
        }
        
        if item.isSeparatorItem || !item.isEnabled {
            return false
        }
        
        let range = item.title.range(
            of: filter,
            options: .caseInsensitive,
            range: nil,
            locale: nil
        )
        
        return (range != nil)
    }
}
