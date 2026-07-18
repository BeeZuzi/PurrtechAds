// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import CharCounterController from "controllers/char_counter_controller"
application.register("char-counter", CharCounterController)

import MultistepFormController from "controllers/multistep_form_controller"
application.register("multistep-form", MultistepFormController)