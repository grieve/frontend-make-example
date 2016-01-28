import Backbone from 'backbone';
import AppView from './app-view';


class AppRouter extends Backbone.Router {

    constructor() {
        super();
        this.appView = new AppView();
        this.routes = {
            '*filter': 'filter'
        };
        this._bindRoutes();
    }

    filter(param='') {
        this.appView.filter(param);
    }

}

export default AppRouter;
