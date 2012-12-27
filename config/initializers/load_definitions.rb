# Parse DSL files and build a hash of data
Vizir::Application.config.dsl = VizirDSL.load_definitions
Vizir::DSL = Vizir::Application.config.dsl
