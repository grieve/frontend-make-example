import Backbone from 'backbone';


class AppView extends Backbone.View {

    constructor() {
        super({
            el: '#main',
            events: {
            }
        });
    }

    render() {
    }

    filter(param) {
        console.log(param);
    }
}

export default AppView;
