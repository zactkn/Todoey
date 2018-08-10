import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    let realm = try! Realm()
    var items: Results<Item>?
    var category: Category? {
        didSet {
            fetch()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try self.realm.write {
                    item.done = !item.done
                }
            } catch {
                print("error persisting item with error: \(error)")
            }
            fetch()
        }
    }
    
    //MARK - Add new items
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var itemTextField = UITextField()
        
        let prompt = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            if let category = self.category {
                do {
                    try self.realm.write {
                        let item = Item()
                        item.title = itemTextField.text!
                        item.dateCreated = Date()
                        category.items.append(item)
                    }
                } catch {
                    print("error persisting item with error: \(error)")
                }
                self.tableView.reloadData()
            }
        }
        prompt.addTextField { (textField) in
            itemTextField = textField
            itemTextField.placeholder = "Add new item"
        }
        prompt.addAction(add)
        present(prompt, animated: true, completion: nil)
    }
    
    func persist(item: Item) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("error persisting item \(item) with error: \(error)")
        }
        tableView.reloadData()
    }
    
    func fetch(with filterO: NSPredicate? = nil) {
        items = category?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        if let filter = filterO {
            items = items?.filter(filter)
        }
        
        tableView.reloadData()
    }
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let filter = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        fetch(with: filter)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            fetch()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
