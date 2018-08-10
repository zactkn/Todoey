import UIKit
import RealmSwift

class CategoryTableViewController: UITableViewController {
    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.text = "<Add categories>"
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationViewController.category = categories?[indexPath.row]
        }
    }

    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        var categoryTextField = UITextField()
        
        let prompt = UIAlertController(title: "New category", message: "", preferredStyle: .alert)
        prompt.addTextField { (textField) in
            categoryTextField = textField
            categoryTextField.placeholder = "Add new category"
        }
        
        let add = UIAlertAction(title: "Add", style: .default) { (action) in
            let category = Category()
            category.name = categoryTextField.text!
            
            self.persist(category: category)
            self.tableView.reloadData()
        }
        prompt.addAction(add)
        present(prompt, animated: true, completion: nil)
    }
    
    func fetch() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func persist(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("error persisting instances with error: \(error)")
        }
    }
}
