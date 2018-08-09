import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    var items = [Item]()
    let persistance = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var category: Category? {
        didSet {
            let filter: NSFetchRequest<Item> = Item.fetchRequest()
            filter.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            fetch(with: filter)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].done = !items[indexPath.row].done
        persist()
    }
    
    //MARK - Add new items
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var itemTextField = UITextField()
        
        let prompt = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            let item = Item(context: self.persistance)
            item.title = itemTextField.text!
            item.done = false
            item.category = self.category
            
            self.items.append(item)
            self.persist()
            self.tableView.reloadData()
        }
        prompt.addTextField { (textField) in
            itemTextField = textField
            itemTextField.placeholder = "Add new item"
        }
        prompt.addAction(add)
        present(prompt, animated: true, completion: nil)
    }
    
    func persist() {
        do {
            try persistance.save()
        } catch {
        }
        tableView.reloadData()
    }
    
    func fetch(with filter: NSFetchRequest<Item> = Item.fetchRequest(), andPredicate: NSPredicate? = nil) {
        do {
            let predicate = NSPredicate(format: "category = %@", category!)
            if let additionalPredicate = andPredicate {
                filter.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, additionalPredicate])
            } else {
                filter.predicate = predicate
            }
            items = try persistance.fetch(filter)
        } catch {
        }
        tableView.reloadData()
    }
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let filter: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        filter.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetch(with: filter, andPredicate: predicate)
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
