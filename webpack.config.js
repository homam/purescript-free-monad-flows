const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const webpack = require('webpack');
const is_production = process.env.NODE_ENV == 'production'
const production = o => is_production ? o : null;
const development = o => !is_production ? o : null;

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, '.build'),
    filename: 'js/bundle.js'
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js', '.purs']
  },
  module: {
    rules: [
      {
        test: /\.purs$/,
        exclude: /node_modules/,
        loader: 'purs-loader',
        options: {
          spago: true,
          src: [
            'src/**/*.purs'
          ],
          pscIde: true
        }
      },
      {
        test: /\.js|\.ts$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.scss$/,
        use: [
          production({ loader: MiniCssExtractPlugin.loader }),
          development({
            loader: 'style-loader', options: {
              insert: 'head',
              injectType: 'singletonStyleTag'
            }
          }),
          { loader: 'css-loader' },
          { loader: 'sass-loader' }
        ].filter(x => !!x),
      }
    ]
  },
  plugins: [
    new CleanWebpackPlugin(),
    production(new MiniCssExtractPlugin({
      filename: '[name].css',
      chunkFilename: '[id].css',
    })),
    new HtmlWebpackPlugin({
      filename: 'index.html',
      template: './src/index.html'
    }),
    development(new webpack.HotModuleReplacementPlugin())
  ].filter(x => !!x),
  devServer: {
    hot: true
  }
};