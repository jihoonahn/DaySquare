import ProjectDescription
import TuistUI

let workspace = DaySquare().module()

struct DaySquare: Module {
    var body: some Module {
        Workspace {
            Path("Projects/App")
        }
    }
}
