module.exports = {
    watch: false,
    devtool: 'source-map',
    module: {
        loaders: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                loader: 'babel',
                query: {
                    presets: ['es2015', 'stage-2']
                }
            }
        ]
    }
};
