import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

//        itemArray.append(Item(title: "Get well", done: false))
//        itemArray.append(Item(title: "Continue with studies", done: false))
//        itemArray.append(Item(title: "Have a nice supper", done: false))
//        itemArray.append(Item(title: "Thank God for all He has done for you", done: false))
        
        if let items = UserDefaults.standard.array(forKey: "itemArray") as? [Item] {
            itemArray = items
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        var item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = itemArrayitem.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        tableView.reloadData()
    }
    
    //MARK - Add new items
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            self.itemArray.append(Item(title: textField.text!, done: false))
            self.defaults.set(self.itemArray, forKey: "itemArray")
            self.tableView.reloadData()
        }
        alert.addTextField { (localTextField) in
            textField = localTextField
            textField.placeholder = "Add new item"
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
