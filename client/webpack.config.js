
'use strict';

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');
const isWebpackDevServer = process.argv.some(a => path.basename(a) === 'webpack-dev-server');
const isWatch = process.argv.some(a => a === '--watch');

module.exports = {
  devtool: 'eval-source-map',

  mode: "development",

  devServer: {
    contentBase: path.resolve(__dirname, '../public'),
    port: 4008,
    stats: 'errors-only'
  },

  entry: './src/index.js',

  output: {
    path: path.resolve(__dirname, '../public'),
    filename: 'dist/bundle.js'
  },

  module: {
    rules: [
      {
        test: /\.purs$/,
        use: [
          {
            loader: 'purs-loader',
            options: {
              src: [
                'src/**/*.purs'
              ],
              spago: true,
              watch: isWebpackDevServer || isWatch,
              pscIde: true
            }
          }
        ]
      },
      {
        test: /\.(png|jpg|gif)$/i,
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: 8192,
            },
          },
        ],
      },
    ]
  },

  resolve: {
    modules: [ 'node_modules' ],
    extensions: [ '.purs', '.js']
  },

  plugins: [
    new webpack.LoaderOptionsPlugin({
      debug: true
    })
  ]
};
