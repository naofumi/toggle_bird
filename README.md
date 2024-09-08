# ToggleBird

[Feature Toggles/Flags](https://www.martinfowler.com/articles/feature-toggles.html) are a popular way to switch on and off 
various parts of your application.

ToggleBird is a very concise implementation of Feature Toggles with no external dependencies, and only about 50 lines of implementation code. Toggles are defined inside your code using plain Ruby. This gives us the flexibility to define conditions either using simple expressions or any callables (lambdas, procs or classes with a `#call` method).

A common gem for managing Feature Toggles in your Ruby apps is [Flipper](https://github.com/flippercloud/flipper). 
Unlike ToggleBird, Flipper manages Feature Toggles inside your database, allowing you to flip toggles in real-time, without having to re-deploy your application. 
ToggleBird, on the other hand, manages all your toggles inside your code. This has the benefit of simpler toggle management – you have a single file that tells you which toggles are available and deployed.  

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage overview

### Installation

Install by adding the ToggleBird gem into your gem file with the following commands in the command line.
```
> bundle add toggle_bird
> bundle install
```

### Minimal definition of a Feature Toggle 

Start by creating a model class in your `app/models` folder. Here we create a `FeatureToggle` class with the filename
`feature_toggle.rb`

**app/models/feature_toggle.rb**

```ruby
class FeatureToggle < ToggleBird::Base
  toggle :true_toggle, true
end
```

### Using the Feature Toggle to switch between code in your application

Go to any ERB template and add the following snippets. Go to the URL where
this ERB template is displayed and observe how the `FeatureToggle` controls which
HTML is rendered.

You can also change `toggle :true_toggle, true` above to `toggle :true_toggle, false`
and see how the display is reversed.

```erbruby
<% if FeatureToggle.enabled? :true_toggle %>
  <div>This will be shown when true toggle is true</div>
<% end %>
```

```erbruby
<% if FeatureToggle.disabled? :true_toggle %>
  <div>This will be shown when true toggle is false</div>
<% end %>
```

This is how ToggleBird allows you to centrally manage which code will be executed
in your application. In the following sections, we will provide details on other
ways to use ToggleBird to provide flexible switching based on any condition that you
can evaluate.

## Details of how to use ToggleBird

### Defining Feature Toggles

Now that we've gone through the overview, from here I will describe the detailed interface.
I'll start by how you define the Feature Toggles, then go through the different ways you can
use them, and finally show some specific examples in Ruby on Rails code.

To define Feature Toggles, we use the `ToggleBird.toggle` method. In addition to the
example we provided earlier, we can use any callable.

```ruby
class FeatureToggle < ToggleBird::Base
  toggle :hidden_feature, false
  toggle :feature_only_shown_in_development, Rails.env.development?
  toggle :feature_only_shown_to_admin, -> (user) { user&.is_admin? }
end
```

In the first example, we provide a value as the second argument to `toggle`. 
As a result, `FeatureToggle.enabled? :hidden_feature` will always evaluate to `true`
whereas `FeatureToggle.disabled? :hidden_feature` will always evaluate to `false`.

In the second example, we provide an expression as the second argument to `toggle`.
The expression will be evaluated once when Rails is loaded. As a result,
`FeatureToggle.enabled? :feature_only_shown_in_development` will always evaluate to
`true` in the development environment whereas `FeatureToggle.disabled? :feature_only_shown_in_development` will always evaluate to `false`.

In the third example, we provide a lambda/proc or any object that responds to `#call`.
`#call` will be called each time `FeatureToggle.enabled?` or `FeatureToggle.disabled?` is
called in your application. Therefore, you can have different return values depending
on the state of each individual request. You can also send in arguments for evaluation.
As a result, `FeatureToggle.enabled? :feature_only_shown_to_admin, user: current_user`
will evaluate to `true` if `current_user.is_admin?` is `true`, and false otherwise.

### Using Feature Toggles

In the above examples, we used `FeatureToggle.enabled?` and `FeatureToggle.disabled?` which
gave us boolean values. These values were used inside `if` statements to select which
code fragment would be executed.

For additional convenience, we also provide additional ways to check the toggle state. These are 
summarized below.

#### Use in combination with `if` statements

`FeatureToggle.enabled?` will return a boolean value and so you can use this in `if` statements like so.

```ruby
if FeatureToggle.enabled? :new_feature
  [code to run when enabled? true]
else
  [code to run when enabled? false]
end
```

#### Use with blocks

In addition to `if` statements, you can use blocks. This makes the code look slightly nicer (in my opinion).

```ruby
FeatureToggle.enabled? :new_feature do
  [code to run when enabled? true]
end
```

#### Use in a single statement

When we want to flip a CSS class name in an HTML element, it is a bit clumsy to use `if` statements.
In these cases, we write a single statement with two additional arguments which are the return
values when the toggle evaluates to true or false.

```erbruby
link_to 'title', post_path, class: FeatureToggle.enabled?(:new_design, 'text-red', 'text-rose')
```

## Using Feature Toggles inside a Ruby on Rails application

When I first started using Feature Toggles, I struggled to understand how they would be used inside
a real Ruby on Rails application. The articles that I found on the internet described how to
use Feature Toggles in general and how they can be useful. However, there was almost no information
on how I could implement this inside a Ruby on Rails application, and what abilities it would
provide.

In this section, I would like to go through very specific cases and describe how I implemented
Feature Toggles to solve each challenge.

### Conditionally hide content or controls inside ERB templates

Using Feature Toggles inside your ERB templates is very common. Here are a couple of examples.

1. You have added a commenting feature to your blog application. Since it is not yet ready to show to all your visitors, you want hide the comment display and entry inputs in production.  
2. You have implemented a search functionality for your blog. There will be a "Search" input field in your top navigation menu, but you want to hide this until it is ready.

In many cases, just hiding a button, some content or an input field will be sufficient to hide the new
feature from your users. This is why it is very common to use Feature Toggles inside ERB templates.

Typically, your code will look like this.

**views/posts/show.html.erb**
```erbruby
...
<% FeatureToggle.enabled? :comment_feature do %>
  <h3>Comments</h3>
  <%= render @post.comments %>
<% end %>
...
```

**views/layouts/application.html.erb**
```erbruby
...
<nav>        
  <% FeatureToggle.enabled? :search_feature do %>
    <%= render 'search_form' %>
  <% end %>
</nav>
...
```

### Blocking access to a route or controller action

In addition to hiding links or buttons to the pages that implement a new feature, you may want to block access to users who have either guessed or somehow figured out the URL for the new feature that is not yet releasable. This is a good idea if you want to make sure that your new feature remains hidden.

For example, you may have a search results page with the path `/search?query=[query string]` which 
is connected to the `SearchController#index` action. Your `routes.rb` file may contain something like this

```ruby
...
resource 'search', only: [:show]
...
```

Your controller may look like this.
```ruby
class SearchesController < ApplicationController
  def show
    @results = Search.results(params[:query])
  end
end
```

The Feature Toggle settings file may look like this so that the 
`:search_feature` toggle will only be true in non-production environments.
```ruby
class FeatureToggle < ToggleBird::Base
  toggle :search_feature, !Rails.env.production?
end
```

Here you have 2 options.

1. You could block access in `routes.rb`.
2. You could block access inside `SearchesController`.

I will describe how to implement both approaches below.

#### Blocking accesses in `routes.rb`

The `constraints` scope together with a lambda is a very clean way to use Feature Toggles inside `routes.rb`. The code should look like the following.

```ruby
...
constraints ->(_req) { FeatureToggle.enabled? :search_feature } do        
  resource 'search', only: [:show]
end  
...
```

#### Blocking accesses in `SearchesController`

Using Feature Toggles inside a controller may be preferable to use inside the router, especially if you want finer control and/or access to methods only available in the controller. For example, it will be easier to block individual controller actions this way. Also, if you want to use `current_user`, using Feature Toggles in the controller will generally be cleaner.

The controller may look like this.
```ruby
class SearchesController < ApplicationController
  before_action only: [:show] do |controller|
    raise AbstractController::ActionNotFound unless FeatureToggle.enabled?(:search_feature)
  end
  
  def show
    @results = Search.results(params[:query])
  end
end
```

#### Using Feature Toggles to switch JavaScript and CSS code

Since we cannot use Ruby code inside JavaScript and CSS, we need to find an indirect way of either replacing the JavaScript/CSS assets altogether, or sending the state of the Feature Toggle to JavaScript/CSS.

To change how you load the JavaScript/CSS assets, you can use Feature Toggles inside the <head> tag to selectively load the assets based on the Feature Toggle state. This is suitable if you are doing a large redesign (see below) but is less preferable for small changes.

You could also add classes to the `<body>` tag.

#### Using Feature Toggles in other parts of your code

In our experience, views and controllers tend to be where we place Feature Toggles the most. This is similar to how you would place your Pundit or CanCan authorizations, which are most often also in the same locations. However, since Feature Toggles are simply centrally managed `if` statements, you are free to use them anywhere you wish inside your code.

The code will probably look something like this, although you are free to use any method that is described in the **Using Feature Toggles** section.

```ruby
FeatureToggle.enabled? :new_feature do
  [code to run when enabled? true]
end
```

### Using Feature Toggles in variants for a front-end redesign of your application

Sometimes you may want to use a completely new ERB template for a redesign of your web application.
You might want to show the new version on staging while the product owner, designer, and QA provide
last minute feedback and do manual testing, but still maintain the old one on your production
environment.

This can be achieved using a combination of Feature Toggles and the Rails variant feature.


### Feature Toggles and Authorization

In terms of what they actually do, Feature Toggles and Authorization (for example the Pundit or CanCan
gems) are very similar. They allow or forbid access to certain parts of the application depending
on certain conditions. 

However, the intent is very different. Feature Toggles are meant to be temporary and cross-cutting. 
On the other hand, Authorization is permanent part of the application, and in case of the Pundit
and CanCan gems, authorization is organized mainly by grouping into the resources that are to be
accessed.

Therefore, it is wise to manage these two separately. Feature Toggles should be regularly cleaned up,
and if you have too many of them in your application, you need to reduce them.

I have seen cases where developers who are new to a project mistakenly use Feature Toggles instead 
of Authorization. If this becomes rampant, you will have difficultly sorting this out. Try to 
proactively prevent this.












Basic Feature Toggle implementation

Specify where to turn code on/off using Feature Toggles.
============================

When using FeatureToggle to control application code
-------------

Inside `app/lib/feature_toggle.rb` add the following code
to configure the value to be returned when calling `FeatureToggle.enabled?`.

```
toggle [toggle name], [value]
```

[value] can be an expression or it can be a proc that returns
a value when called.

Assuming that we have set the toggle :coding_test as follows.

```
toggle :coding_test, false
```

Then inside the application code, you can enable/disable features
like this.

```
if FeatureToggle.enabled? :coding_test
  [code to run when enabled? true]
else
  [code to run when enabled? false]
end
```

You can also provide default true and false values as arguments to `FeatureToggle.enabled?`.
This allows you to be more concise in some cases.

```
link_to 'CTA title', cta_path, class: FeatureToggle.enabled?(:optimise_cta, 'text-warning', 'text-info')
```

You can also use `FeatureToggle.disabled?` which simply inverts the logic like so.

if FeatureToggle.disabled? :coding_test
  [code to run when enabled? false]
else
  [code to run when enabled? true]
end

Essentially, `FeatureToggle.enabled?` and `FeatureToggle.disabled?`
return the values that you set in `app/models/feature_toggle.rb`
with the added benefit that you can also use Procs to delay evaluation
if necessary.

FeatureToggle.enabled? :coding_test
=> false

FeatureToggle.disabled? :coding_test
=> true

Using FeatureToggle inside the Router
---------------

If you use it in routes.rb, there are some gotchas.
In development and test environments, routes.rb is not reloaded for each
test and remains in memory.

Therefore, you want the FeatureToggle code to be late evaluated. To
do this, you can wrap the FeatureToggle inside a `constraints`
declaration with a lambda (closure).

constraints: -> { FeatureToggle.enabled? :skill_assessment } do
  resources :skills
end

Note that from the routes.rb, you will not have access to functions like
`current_user`. This is because the Rails router is run before the Rails
controllers.

If you need to toggle features based on the `current_user`, it is better
to toggle inside the Controller and not the Router. Alternatively,
you may be able to access Rack middleware environments with `request.env['warden']`
inside `routes.rb` inside a `constraints` declaration

Using FeatureToggle inside the Controller
----------------

When restricting access to actions, use something like the following code.

```
def SomeController < ApplicationController
  before_action only: [:index, :show] do |controller|
    raise AbstractController::ActionNotFound unless FeatureToggle.enabled?
  end
end
```

`raise AbstractController::ActionNotFound` will generate a 404 response.

Switching the FeatureToggle value in your tests
===========================

It is a good idea to test with both your FeatureToggle on and off.

To temporarily change the value of a toggle in a test, you can use the
following code.

```
FeatureToggle.toggle :coding_test, false
```

Alternatively, you can write

```
it 'some test' do
  FeatureToggle.toggle :coding_test, false do
    [test to run when :coding_test is false]
  end
end
```

The later method using a block will automatically reset the FeatureToggle
value back to the original value so this is generally preferred. When
using the former syntax, you need to reset the FeatureToggle back to
the original -- otherwise, it may affect other tests.

If you want to set FeatureToggle for many tests, use an around filter
like the following.

```
around do |example|
  FeatureToggle.toggle :coding_test, false, &example
end
```

Other stuff
=============================

Dynamically changing the value of a FeatureToggle using a block
---------------------------

It is common to change the value of a FeatureToggle depending on
the current_user. For example, this allows us to show a feature to
a QA dev while hiding the feature to other users in production.

To do this, add something like this code to `app/models/feature_toggle.rb`.

This will allow evaluation of the toggle value to be delayed until
`FeatureToggle.enabled?` is called. If the value is directly coded in
`app/models/feature_toggle.rb` without wrapping it in a lambda, then
the code will be only evaluated once when the server is started.

```
class << self
  def user_is_namihei_or_admin_is_admin_2?
    (Current.user && Current.user.email == 'namihei@example.com') ||
       (Current.admin && Current.admin.email == 'admin_2@example.com')
  end
end

toggle :manager_user_show, -> { user_is_namihei_or_admin_is_admin_2?}
```




















## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/naofumi/toggle_bird.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
