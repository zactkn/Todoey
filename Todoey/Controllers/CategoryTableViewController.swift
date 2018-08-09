import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    var categories = [Category]()
    let persistance = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categories[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = category.name
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationViewController.category = categories[indexPath.row]
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
            let category = Category(context: self.persistance)
            category.name = categoryTextField.text!
            
            self.categories.append(category)
            self.persist()
            self.tableView.reloadData()
        }
        prompt.addAction(add)
        present(prompt, animated: true, completion: nil)
    }
    
    func fetch(with filter: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try persistance.fetch(filter)
        } catch {
            print("error fetching instances with error: \(error)")
        }
        tableView.reloadData()
    }
    
    func persist() {
        do {
            try persistance.save()
        } catch {
            print("error persisting instances with error: \(error)")
        }
    }
}
