import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

// Import and register all controllers
import ApprovePostController from "./controllers/approve_post_controller"
import DeclinePostController from "./controllers/decline_post_controller"
import GenController from "./controllers/gen_controller"
import MorePostsLoaderController from "./controllers/more_posts_loader_controller"
import SubmitContentLoaderController from "./controllers/submit_content_loader_controller"
import SubmitController from "./controllers/submit_controller"
import TermsController from "./controllers/terms_controller"
import UpdatePostController from "./controllers/update_post_controller"

application.register("approve-post", ApprovePostController)
application.register("decline-post", DeclinePostController)
application.register("gen", GenController)
application.register("more-posts-loader", MorePostsLoaderController)
application.register("submit-content-loader", SubmitContentLoaderController)
application.register("submit", SubmitController)
application.register("terms", TermsController)
application.register("update-post", UpdatePostController)
