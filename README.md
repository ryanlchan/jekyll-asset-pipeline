# Jekyll Asset Pipeline

[Jekyll Asset Pipeline](http://www.matthodan.com/2012/11/22/jekyll-asset-pipeline.html) is a powerful asset pipeline for Jekyll.  It collects, converts and minifies JavaScript and CSS assets.  Here are a sample of its features:

- Declaritive dependency management
- Asset preprocessing and compression
- MD5 fingerprinting for browser caching
- Development mode (i.e. no asset compression)
- Works with Jekyll's auto site regeneration

Jekyll Asset Pipeline adds the ability to write assets in languages such as [CoffeeScript](http://coffeescript.org/), [Sass](http://sass-lang.com/), or any other language you like via [asset converter extensions](#asset-preprocessing).  It also adds the ability to minify assets with Yahoo's [YUI Compressor](http://developer.yahoo.com/yui/compressor/), Google's [Closure Compilier](https://developers.google.com/closure/compiler/), or any other compression library via [asset compressor extensions](#asset-compression).

## Table of Contents

- [Getting Started](#getting-started)
- [Asset Compression](#asset-compression)
- [Asset Preprocessing](#asset-preprocessing)
- [Templates](#templates)
- [Configuration](#configuration)
- [Contribute](#contribute)
- [Credits](#credits)

## Getting Started

Jekyll Asset Pipeline is extremely easy to add to your Jekyll project and has no incremental dependacies beyond those already required by Jekyll.  Once you have a basic Jekyll site up and running, simply follow the following steps to install and configure Jekyll Asset Pipeline.

Install the "jekyll-asset-pipeline" gem via [Rubygems](http://rubygems.org/).

``` bash
gem install jekyll-asset-pipeline
```

> *If you are using [Bundler](http://gembundler.com/) to manage your project's gems, you can just add "jekyll-asset-pipeline" to your Gemfile and run `bundle install`.*

Add a "_plugins" folder to your project (if you do not already have one).  Within the "_plugins" folder, add a file named "jekyll_asset_pipeline.rb" with the following code.

``` ruby
require 'jekyll_asset_pipeline'
```

Add a "_assets" folder to your project and copy your JavaScript and CSS assets into the folder.  We want Jekyll to ignore these files since we will be including these files via a bundle that is generated by Jekyll Asset Pipeline.

In the HTML "head" section of your default layout (or other HTML page) of your Jekyll site, add one or both of the following [Liquid](http://liquidmarkup.org/) blocks and replace "foo" and "bar" with your asset files.  These blocks will be converted into HTML "link" and "script" tags that point to the bundled asset files.  The manifest must be a properly formatted YAML array and must include paths to your raw assets from the root folder of your project.

``` html
{% css_asset_tag global %}
- /_assets/foo.css
- /_assets/bar.css
{% endcss_asset_tag %}

{% javascript_asset_tag global %}
- /_assets/foo.js
- /_assets/bar.js
{% endjavascript_asset_tag %}
```

> *The above example will create two bundles, a CSS bundle named "global-md5hash.css" and a JavaScript bundle named "global-md5hash.js" that include their respective assets per the manifest.*

Run the `jekyll` command so that Jekyll compiles your site.  You should see an output that includes the following Jekyll Asset Pipeline status messages.

``` bash
Asset Pipeline: Compiling bundle... compiled 'global-md5hash.css'.
Asset Pipeline: Compiling bundle... compiled 'global-md5hash.js'.
```

> *If you do not see these messages, check that you have __not__ set Jekyll's "safe" option to "true" via a "_config.yml" file.  If the "safe" option is set to "true", Jekyll will not run third-party plugins.*

That's it!  You now have an asset pipeline.  Look in the "_site" folder of your project and you should see an "assets" folder that contains the bundled assets.  You should also see tags that point to these assets in your HTML markup where you included the Liquid blocks.

## Asset Compression

Adding compression with your favorite minification library is trivial with Jekyll Asset Pipeline.  In the following example, we will add a custom compressor extension that uses Yahoo's YUI Compressor to compress our CSS and JavaScript assets.

In the "jekyll_asset_pipeline.rb" file that we created in the "Getting Started" section of this post, add the following code to the end of the file (i.e. after the "require" statement we added previously).

``` ruby
module JekyllAssetPipeline
  class CssCompressor < JekyllAssetPipeline::Compressor
    require 'yui/compressor'

    def self.filetype
      '.css'
    end

    def compress
      return YUI::CssCompressor.new.compress(@content)
    end
  end

  class JavaScriptCompressor < JekyllAssetPipeline::Compressor
    require 'yui/compressor'

    def self.filetype
      '.js'
    end

    def compress
      return YUI::JavaScriptCompressor.new(munge: true).compress(@content)
    end
  end
end
```

The above code adds a CSS and a JavaScript compressor.  You can name the class of a compressor anything as long as it inherits from "JekyllAssetPipeline::Compressor".

The "self.filetype" method defines the type of asset a compressor will process (either '.js' or '.css').  The "compress" method is where the magic happens.  A "@content" instance variable that contains the raw content of our bundle is made available within the compressor.  The compressor should process this content and return the processed content (as a string) via a "compress" method.

If you haven't already, you should now install any dependencies that are required by your compressor.  In our case, we need to install the "yui-compressor" gem.

``` ruby
gem install yui-compressor
```

> *If you are using [Bundler](http://gembundler.com/) to manage your project's gems, you can just add "yui-compressor" to your Gemfile and run `bundle install`.*

Run the `jekyll` command so that Jekyll compiles your site.

That's it!  Your asset pipeline should have compressed your CSS and JavaScript assets.  You can verify that this is the case by looking at the contents of the bundles generated in the "_site/assets" folder of your project.

## Asset Preprocessing

Asset preprocessing (i.e. conversion) allows us to write our assets in languages such as [CoffeeScript](http://coffeescript.org/), [Sass](http://sass-lang.com/), or any other language we like.  Adding asset preprocessing is trivial with Jekyll Asset Pipeline.  In the following example, we will add a custom converter extension that converts CoffeeScript into JavaScript.

### CoffeeScript

In the "jekyll_asset_pipeline.rb" file that we created in the "Getting Started" section of this post, add the following code to the end of the file (i.e. after the "require" statement we added previously).

``` ruby
module JekyllAssetPipeline
  class CoffeeScriptConverter < JekyllAssetPipeline::Converter
    require 'coffee-script'

    def self.filetype
      '.coffee'
    end

    def convert
      return CoffeeScript.compile(@content)
    end
  end
end
```

> *If you already added a compressor, you can include your converter class alongside your compressor within the same JekyllAssetPipeline module.*

The above code adds a CoffeeScript converter.  You can name the class of a converter anything as long as it inherits from "JekyllAssetPipeline::Converter".

The "self.filetype" method defines the type of asset a converter will process (e.g. ".coffee" for CoffeeScript) based on the extension of the raw asset file.  The "convert" method is where the magic happens.  A "@content" instance variable that contains the raw content of our asset is made available within the converter.  The converter should process this content and return the processed content (as a string) via a "convert" method.

If you haven't already, you should now install any dependancies that are required by your converter.  In our case, we need to install the "coffee-script" gem.

``` bash
gem install coffee-script
```

> *If you are using [Bundler](http://gembundler.com/) to manage your project's gems, you can just add "coffee-script" to your Gemfile and run `bundle install`.*

Run the `jekyll` command so that Jekyll compiles your site.

That's it!  Your asset pipeline should have converted any CoffeeScript assets into JavaScript and included them in their respective bundle.  You may need to disable compression (if you added a compressor) to be able to clearly view the result.

### SASS

You probably get the gist of how converters work, but I thought I'd add an example showing how to add a SASS converter as well.

``` ruby
module JekyllAssetPipeline
  class SassConverter < JekyllAssetPipeline::Converter
    require 'sass'

    def self.filetype
      '.scss'
    end

    def convert
      return Sass::Engine.new(@content, syntax: :scss).render
    end
  end
end
```

> *Don't forget to install the "sass" gem before you run the `jekyll` command since our SASS converter requires this library as a dependency.*

## Templates

When Jekyll Asset Pipeline creates a bundle, it returns an HTML tag that points to the bundled file.  This tag is either a "link" tag for CSS or a "script" tag for JavaScript.  Under most circumstances the default tags will suffice, but you may want to customize this output for special cases (e.g. if you want to use CSS media types).

In the following example, we will override the default CSS link tag by adding a custom template that produces a link tag with a "media" attribute.

In the "jekyll_asset_pipeline.rb" file that we created in the "Getting Started" section of this post, add the following code to the end of the file (i.e. after the "require" statement we added previously).

``` ruby
module JekyllAssetPipeline
  class CssTagTemplate < JekyllAssetPipeline::Template
    def self.filetype
      '.css'
    end

    def html
      "<link href='/#{@path}/#{@filename}' rel='stylesheet' type='text/css' media='screen' />\n"
    end
  end
end
```

> *If you already added a compressor and/or a converter, you can include your template class alongside your compressor and/or converter within the same JekyllAssetPipeline module.*

The “self.filetype” method defines the type of bundle a template will target (either ".js" or ".css").  The “html” method is where the magic happens.  “@path” and "@filename" instance variables are available within the class and contain the path and filename of the generated bundle, respectively.  The template should return a string that contains an HTML tag pointing to the generated bundle via an "html" method.

Run the `jekyll` command so that Jekyll compiles your site.

That’s it! Your asset pipeline should now use your template to generate a HTML "link" tag that includes a media attribute with the value "screen".  You can verify this is the case by viewing the generated source within your project's "_site" folder.

## Configuration

Jekyll Asset Pipeline provides the following two configuration options that can be controled by adding the following to the end of your project's "_config.yml" file.

``` yaml
asset_pipeline:
  compress: true          # Default = true
  output_path: assets     # Default = assets
```

> *If you don't have a "_config.yml" file, consider reading the [configuration section](https://github.com/mojombo/jekyll/wiki/Configuration) of the Jekyll documentation.*

The "compress" setting tells Jekyll Asset Pipeline whether or not to compress the bundled assets.  It is useful to set this setting to "false" while you are debugging your site's JavaScript.  The "output_path" setting defines where generated bundles should be saved within the "_site" folder of your project.

## Contribute

You can contribute to the Jekyll Asset Pipeline by submitting a pull request [via GitHub](https://github.com/matthodan/jekyll-asset-pipeline).

Key areas that I have identified for future improvement include:

- __Tests, tests, tests.__  I'm embarassed to say that I didn't write a single test while building Jekyll Asset Pipeline.  This started as a hack for my blog and quickly grew into a library as I tweaked it to support my own needs.
- __CDN support.__ Jekyll Asset Pipeline should support using a CDN to host your assets.
- __Handle remote assets.__ Right now, Jekyll Asset Pipeline does not provide any way to include remote assets in bundles unless you save them locally before generating your site.  Moshen's [Jekyll Asset Bundler](https://github.com/moshen/jekyll-asset_bundler) allows you to include remote assets, which I thought was pretty interesting.  That said, I think it is generally better to keep remote assets separate so that they load asynchronously.
- __Documentation.__ I wrote this readme to introduce people to Jekyll Asset Pipeline, but there should be docs that can be easily maintained.
- __Successive preprocessing.__ Currently you can only preprocess a file once.  It would be better if you could run an asset through multiple preprocessors before it gets compressed and bundled.

Feel free to [message me on GitHub](http://github.com/matthodan) if you want to run an idea by me.

## Credits

As I was building Jekyll Asset Pipeline, I came across a number of tools that I was able to draw inspiration and best practices from, but one stood out in particular...  I have to give credit to [Moshen](https://github.com/moshen/) for creating the [Jekyll Asset Bundler](https://github.com/moshen/jekyll-asset_bundler).

Jekyll Asset Bundler *almost* covered all of my needs when I set out to find an asset pipeline solution for my blog.  The big missing features in my opinion were support for CoffeeScript and Sass.  It also lacked a way to easily add new preprocessors that would have let me easily add support for these converters.

I also have to give credit to [Mojombo](https://github.com/mojombo) for creating [Jekyll](https://github.com/mojombo/jekyll) in the first place.

---

Like this project?  You may want to read [my blog](http://www.matthodan.com).
