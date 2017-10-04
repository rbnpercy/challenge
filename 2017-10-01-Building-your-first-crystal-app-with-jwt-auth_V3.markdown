---
layout: post
title: "Building your first Crystal Web App &amp; Authenticating with JWTs"
description: "Continuing on from my Introduction to Crystal article, this time we're going to build our first Crystal Web App and Authenticate Users via JSON Web Tokens."
date: 2017-10-01 09:13
category: Technical Guide
author:
  name: "Robin Percy"
  url: "https://twitter.com/rbin"
  mail: "robin@percy.pw"
  avatar: "https://secure.gravatar.com/avatar/685342d5e7f42c3ab8d251d7d4a53308?s=100&d=mm&r=g"
tags:
- crystal-language
- jwt-authentication
- json-web-tokens
---


Building your first Crystal Web App &amp; Authenticating with JWTs
==========================================

I wrote a technical article back in June titled ["The Highs &amp; Lows of Crystal"](https://auth0.com/blog/an-introduction-to-crystal-lang/).  It was an introduction to the Crystal Language and an overview of my perspective on it, trying it out for the first time. I enjoyed trying out Crystal very much and the good news is that Crystal is still on the up, and more than ever people are trying it out, and finding that they really rather like it (just as I do!)

Today I'd like to share a guide on building your first Web App with *Crystal,* and using *JSON Web Tokens* (JWTs) to authenticate users in said application.  Before we dive into the technical tutorial, for those who haven't read the previous article, and perhaps don't know about Crystal Language at all, I'd like to quickly introduce it.

Crystal was introduced by its creator, Ary Borenszweig, back in mid-2014 as a general purpose, object-oriented language with the aim of giving speeds close to C/C++ and being heavily syntactically influenced by Ruby.  Crystal is a statically-typed, garbage collected language, boasting the speed, efficiency and type safety of a *compiled* language.

Crystal runs on the [LLVM](https://llvm.org/), and although the *feel* of the language is rather similar to Ruby, Crystal compiles down to much more efficient code, with much greater processing speeds.  It is also self-hosted with the Crystal compiler actually being written in Crystal itself.  As I mentioned in my previous Crystal introduction, the language is built to support concurrency primitives right out of the box, and uses similar concurrency concepts (including lightweight threading) to languages like [Golang](https://golang.org/) and [Elixir](https://elixir-lang.org).

Two of the things I like most about Crystal are the excellent built-in tooling available, and the ease with which you can bind C libraries. When I look at new languages, especially relatively immature languages, it's always very reassuring when the language has extensive built-in tooling available to help developers stay productive and happy! In Crystal, there are a bunch of tools that make hacking around in the language super fun, but also help us to stay on the right track with semantics and more.  I touched on those topics in a bit more detail in my [previous article](https://auth0.com/blog/an-introduction-to-crystal-lang).

So that's Crystal in a nutshell!  And now we have that covered, we can get on with building our first Crystal web application, and authenticating our app users with JWTs.  If you would like to see the completed sample application to follow along with this article, it can be [found in this GitHub repo.](https://github.com/rbnpercy/challenge)


## Web App concept TL;DR

The idea behind the web app that we're going to build is a community driven Coding Challenge app in which members of the Open Source community can set coding challenges, and other members of the community can take the challenge and provide the solution.  The joy of this app would be that coding challenges would have a whole array of solutions, in many different languages.  They could act as great learning resources to others in the developer community, alongside being a fantastic learning experience in solving the challenge itself.  (An idea I'd *love* if someone were to build and launch in the real world!)

In our app members of the community will have to be authorised to post and access the coding challenges, and therefore we're going to need a means of authentication.  For that, we're going to use [***JSON Web Tokens***](https://jwt.io/).  We also need to store the challenges posted, for that we'll use standard *MySQL* as our database. 


## Installing Crystal Lang

If you run on a Mac, you can install Crystal through *Homebrew*.  Simply run:

~~~ bash
brew update
brew install crystal-lang
~~~

If you run on Debian or Ubuntu, you can install through *apt-get*:

~~~ bash
sudo apt-get install crystal
~~~

One thing worth noting is that if you are going to install onto Ubuntu or Debian, you must first add the repository and signing key to your APT configuration.  It's super simple to do, and instructions can be [found here.](https://crystal-lang.org/docs/installation/on_debian_and_ubuntu.html) 
	
Alternatively, you can build from source with a tar.gz file.  The latest files can be found on the releases page on GitHub: [https://github.com/crystal-lang/crystal/releases](https://github.com/crystal-lang/crystal/releases).

Crystal does not yet have a direct Windows port but *that being said*, if you have Windows 10 onward you can install and run Crystal as normal through the Bash / Ubuntu for Windows Subsystem.  Details for that can be [found here.](https://crystal-lang.org/docs/installation/on_bash_on_ubuntu_on_windows.html) 

To test your installation has worked successfully, simply type `crystal` into your terminal, and you will have returned the Crystal CLI default menu.  Now we have Crystal installed and working on our machines, we can get on with the fun part—building our app!



## Creating our Project

For building our web app, we shall use the popular Crystal web micro-framework [Kemal](http://kemalcr.com).  Kemal is heavily influenced by *Sinatra* for Rubyists, and works in a very similar way.  I can confirm it is a joy to use—being both simple and functional.  Handily, we can scaffold our new project using Crystal's built-in project tooling.  Switch into your development working directory, and run the command:

~~~ bash
crystal init app challenger
~~~

With `challenger` being the name I gave my application.  Feel free to name your project whatever you wish!  Open up the project in your chosen editor, and head over to the file `shard.yml` in the project root.  Much like having a Ruby Gems file, this YML file contains all of the dependencies for our project.  Open up `shard.yml` and add the following:

~~~ yml
dependencies:
  kemal:
    github: kemalcr/kemal
    branch: master
~~~

Once that's in, head back into your terminal and run `shards install`.  Doing this will pull down Kemal and its dependencies for us to utilise.

The main file in your project is located in the `/src` directory and will be named with whatever you called your project, so for me it's: `/src/challenger.cr`.  This file will contain the routes for our *Kemal* app alongside the controller logic, some config for our *Kemal* app, and not much else.  To get our app up and running immediately, open up that file and add in the following:

~~~ crystal
require "./challenge/*"
require "kemal"

module Challenger

  get "/" do
    render "src/challenge/views/home.ecr", "src/challenge/views/layouts/main.ecr"
  end


  Kemal.config.port = 6969
  Kemal.run

end
~~~

The *require* statements at the beginning of the file are telling our app to include Kemal to serve pages, and to include the `src/challenge` folder, which will contain files and folders necessary to our project such as *Config, Models, Views*, etc.  Next, we have defined a route and instructed it to render **two** *ECR* files.  This is because Kemal allows us to create *layout* templates, alongside file-specific views.

To enforce those views, create the *layout* file `src/challenge/views/layouts/main.ecr`:

~~~ html
<html>
<head>
  <title>Challenger // Coding Challenges</title>
  <link rel="stylesheet" href="/css/main.css"/>
</head>
<body>

  <section id="main">
    <div class="container">
      <%= content %>
    </div>
  </section>

  <script src="/js/main.js"></script>
</body>
</html>
~~~

Now create the home ***view*** file `src/challenge/views/home.ecr`, and enter in whatever you like.  I simply included an `<h1> tag` saying hello.

You can now test your application by running `crystal run src/challenger.cr` from your terminal.  Your app should now be running on whichever port you specified—in this case ":6969".


## Setting up User Login with Auth0 Hosted Pages

Now that we've got the base of our app setup, we can move straight onto the good stuff, and the main reason we're all here—authenticating our users with *JWTs*.  With Crystal being a young and relatively immature language, it's no huge surprise that there aren't really any existing user authentication frameworks that we could simply drop into our project, much like we would with *Devise* or *Omniauth* for Ruby / Rails.  Happily however, we don't need one.

We're going to store our users with Auth0 meaning we don't even need a `Users` table in our database.  Auth0 has quickstart guides to pretty much all major languages, but again with Crystal being a fairly new language, it's up to us to build from scratch.  However, Auth0 make this easy for us with good technology, and Crystal makes it a genuine pleasure to write.  

The first thing to do, is open up your [Auth0 management console](https://manage.auth0.com/#) and click on the ***Create Client*** button.  For this app, we can create a *Regular Web Application* client, and name it *Challenge* or whatever you have titled your application.

Then, back in your chosen editor, we need to create some *routes* for our app.  Open up `/src/challenger.cr` and add the following routes:

~~~ crystal
get "/auth/login" do |env|
  env.redirect "https://[YOUR_URL].auth0.com/login?client=[CLIENT_ID]"
end

get "/auth/callback" do |env|
  # callback logic
end

get "/success" do |env|
  # for forwarding people to
end

get "/auth/logout" do |env|
  # log people out
end
~~~

These four routes are the basis for our authentication flow with Auth0.  Since there are, as I stated earlier, no available authentication libraries for our users to log in—we will use *Auth0's hosted pages*.  Note in the `/auth/login` route, we have created a redirect.  This redirect will send users straight to our *Auth0 hosted login page* whenever they access the */auth/login* route.

Once you've added these routes, open up your Auth0 app settings again, scroll down on the *settings* tab for your app and add into the `Allowed Callback URL` section:

	http://localhost:6969/auth/callback
	
We haven't created the callback logic in our app just yet, but this is the route we will assign to it, so we can fill that in already.


## Create Login Callback &amp; get JWT

If you were to boot your application and run through the Login process now, you would see that once successfully logged in, you would simply be presented with the `/auth/callback` page—entirely blank, but with a URL param titled `?code=`.  The way in which the process works can be found in detail [here](https://auth0.com/docs/tokens/access-token), that *code* actually being our Auth0 *Access Token*.  To turn this *Access Code* into a usable JWT that we can pass around our application to authorise our user—we need to silently POST that code, alongside our *App ID* and *Secret* back to Auth0 to verify and exchange for a JWT.  To do this, we shall create a module named *Auth* that will handle this in the background, on our `/auth/callback`.

Create a file in the `/src` directory of your application named `auth.cr`, and add in the following:

~~~ crystal
require "http/client"
require "json"

module Auth
  extend self

  def get_auth_token(id_code)
    id = id_code

    uri = URI.parse("https://[YOUR_DOMAIN].auth0.com/oauth/token")

    request = HTTP::Client.post(uri,
      headers: HTTP::Headers{"content-type" => "application/json"},
      body: "{\"grant_type\":\"authorization_code\",\"client_id\": \"[CLIENT_ID]\",\"client_secret\": \"[CLIENT_SECRET]\",\"code\": \"#{id}\",\"redirect_uri\": \"http://localhost:6969/auth/callback\"}")

    response = request.body

    res = get_jwt(response)
    return res
  end

end
~~~

In the above code, we are creating a module titled *Auth* that we can call in the background from our application.  We have defined a method called `get_auth_token` which takes the argument of `id_code` sent from the successful login of our hosted login.  We then need to send a request to `[YOUR_domain].auth0.com/oauth/token` to exhange this for a usable JWT. 

Using the `http/client` library, we can construct a request that sends a JSON blob containing our `client_id`, `client_secret`, `code`, and `redirect_uri` to Auth0 for verification.  Note that the `code` value here is a string-interpolation of the `Access Code` we received back as a URL param from the Auth0 login.

Also at the end of this method, we are calling another method titled `get_jwt()` that takes the returned JSON blob as its argument.  Let's create that method now, in the same Auth module:

~~~ crystal
class Token
  JSON.mapping(
    access_token: String,
    id_token: String,
    expires_in: Int32,
    token_type: String,
  )
end

def get_jwt(auth_code)
  auth = auth_code

  value = Token.from_json(%(#{auth}))
  jwt = value.id_token

  return jwt
end
~~~

To extract the usable JWT from the JSON blob that was returned in the last method call, we can use Crystal's super-handy `JSON.mapping` functionality.  We have defined a class titled `Token` that we can push the JSON blob into, to create usable values.  In defining the `get_jwt()` method, we are doing that value push into the `Token` object, and returning just the `id_token` value.  This `id_token` is our actual, usable JWT containing our encoded user's details that we will use to authorise them around our application.

Now that we have our Auth module created, we can head back to our main `src/challenger.cr` file, require the module, and call it from our */auth/callback* route:

~~~ crystal
require "./auth"

get "/auth/callback" do |env|
    code = env.params.query["code"]
    jwt = Auth.get_auth_token(code)
    env.response.headers["Authorization"] = "Bearer #{jwt}"
end
~~~

So when a user successfully logs in, their *Access Token* will be sent to our `/auth/callback` route, extracted from the URL params and used to call our Auth module which will return the usable JWT.  We can then set this JWT in our *HTTP Authorization Header* and we're done... Or are we?

If you run your application now, you will realise that after successful login and setting of the JWT in the Authorization header, if you navigate to another page the header disappears entirely.  This is because we need to actually *store* this JWT in LocalStorage either in a *session* or in a *cookie*.  In this case, we are going to use a session, and happily there *is* a [library](https://github.com/kemalcr/kemal-session) built for Kemal to handle the creation of *sessions*.

Add the following into your `shard.yml` file, and run `shards install`:

~~~ yml
kemal-session:
    github: kemalcr/kemal-session
~~~



## Setting the JWT in a User Session

To setup `kemal-session` to carry our JWT Authorization header—in our main `src/challenger.cr` file, remember to *require* kemal-session, and add in the following before your route definitions:

~~~ crystal
Kemal::Session.config do |config|
  config.cookie_name = "sess_id"
  config.secret = "[SOME_SECRET]"
  config.gc_interval = 1.minutes
end

class UserStorableObject
  JSON.mapping({
    id_token: String
  })

  include Kemal::Session::StorableObject

  def initialize(@id_token : String); end
end
~~~
 
To generate a strong `config.secret`, you can run the following and copy / paste the result:

	crystal eval 'require "secure_random"; puts SecureRandom.hex(64)'

Once again here, we are going to create a Class to JSON_map values to.  The only value we need is the id_token here, as this will be our encoded JWT value.  Back to our `auth/callback` route, we can update it to the following:

~~~ crystal
get "/auth/callback" do |env|
  code = env.params.query["code"]
  jwt = Auth.get_auth_token(code)
  env.response.headers["Authorization"] = "Bearer #{jwt}"  # Set the Auth header with JWT.

  user = UserStorableObject.new(jwt)
  env.session.object("user", user)

  env.redirect "/success"
end
~~~

Note that we are creating a `user` object, from the `jwt` value returned from our Auth module.  We are then using that `user` object to set as a `session`, storing the encoded JWT which will now remain when the visitor navigates to another page.  It's now worth updating our `/auth/success` and `/auth/logout` routes too:

~~~ crystal
get "/success" do |env|
  user = env.session.object("user").as(UserStorableObject)
  env.response.headers["Authorization"] = "Bearer #{user.id_token}"

  render "src/challenge/views/success.ecr", "src/challenge/views/layouts/main.ecr"
end

get "/auth/logout" do |env|
  env.session.destroy

  render "src/challenge/views/logout.ecr", "src/challenge/views/layouts/main.ecr"
end
~~~

Great!  We've got our encoded JWT being passed round in our Authorization HTTP Header, we have a successful login redirect, and even a way for the User to logout.  We're not quite finished yet, though.


## Decoding the JWT and Verifying Access

The whole reason we want to pass around a *JWT* in our HTTP Authorization Header is to be able to decode and verify this token, to check whether our users have access to restricted parts of our application.  So what we need to do now is create another Module that will Decode our JWT, verify it and check that it contains an arbitrary attribute stating access levels for our application.

Before we code-up this module, head over to your Application Settings in the Auth0 management console and change a couple of settings.  Firstly, scroll down to the *Advanced Settings* of your application and click on the *OAuth* tab.  The first setting we need to change here is the `JsonWebToken Signature Algorithm` setting.  Ensure that this is set to ***HS256*** and not *RS256*.  

The next setting is `OIDC Conformant` for now, just turn this off as it's not something we need to worry about, and may stop us from allowing login with username/password when using the hosted login.  More information on that can be found [here](https://auth0.com/docs/api-auth/tutorials/adoption)—but for now, don't worry too much about it, just switch it off.  Ensure you **save** these settings before moving on.

In this sample application we are not including an app-specific way for users to register, they can only do so through the hosted login.  In doing so, we can't set any custom attributes to our user on sign up.  Since this is just a demo it's not a problem.  We can go into the user's profile in the ***Users*** section of the Auth0 admin console, and add the following to the `app_metadata` field.

~~~ json
{
  "roles": "member"
}
~~~

Once we've done this, we need to tell Auth0 to return this value in the JWT.  Head into the ***Rules*** section directly below the *Users* section in the navigation.  Click on the *Create Rule* button and select a blank rule.  Have it reflect the following:

~~~ js
function (user, context, callback) {
    var namespace = 'https://localhost:6969';
    if (context.idToken && user.user_metadata) {
      context.idToken.user_metadata = user.user_metadata;
    }
    if (context.idToken && user.app_metadata) {
      context.idToken.app_metadata = user.app_metadata;
    }
    callback(null, user, context);
  }
~~~

By setting this rule, Auth0 will now return the `user_metadata` field in our JWT.  This field contains our user's access level that we can verify before allowing them access to resources.

Moving on, head back into your project, add the Crystal *jwt* module to your `shards.yml` file and run `shards install`:

~~~ yml
jwt:
    github: crystal-community/jwt
~~~

Now, create a file named `user.cr` in the base */src* directory where we created the Auth module earlier.  Have it reflect the following:

~~~ crystal
require "jwt"
require "json"

module User
  extend self

  @@verify_key = "[CLIENT_SECRET]"

  def authorised?(user)
    token = user
    payload, header = JWT.decode(token, @@verify_key, "HS256")
    roles = payload["app_metadata"].to_s
    rs = roles.includes?("member")
    puts rs

    return
  end

end
~~~

The first thing to note here is the `@@verify_key` class variable.  To decode our JWT, it needs a secret key.  This secret key is actually the `Client_Secret` defined in our Auth0 app management console.  (The same one we used earlier when calling for our Auth Token).

Next, we have defined a method called `authorised?()` that will take in the encoded JWT of our User as an argument.  Then, we use the *Crystal JWT* library to decode the JWT using our `Client Secret` as the secret key, and denoting the hashing algorithm to use as `HS256` as we defined earlier in our application *Advanced Settings / Oauth*.  Once decoded, we can check to confirm that the payload of the JWT contains our `app_metadata` attribute of ***roles***, and that it does reflect the user being a `member`.  We can then return the True / False value.

We know that the only parts of our application we want our users to be authorised to view are the coding challenges.  Open up your main `src/challenger.cr` file and add the following route definition, ensuring you include `require "./user"`:

~~~ crystal
before_get "/challenges" do |env|
  user = env.session.object("user").as(UserStorableObject)

  autho = User.authorised?(user.id_token)
  raise "Unauthorized" unless autho = true
end
~~~

Here we are using *Kemal's* `before_get` directive to ensure this method is called before a user can call a resource.  We are setting a `user` object from the stored user JWT in the session, and calling our `User.authorised?()` method on that user / JWT.  Depending on the returned Boolean, we are either raising a *401 Unauthorized*, or allowing access.

***Realistically, this is the crucial part of our application as it is the logic defining resource access from our user's JWT.***


## Extra: Adding the Coding Challenges

As this article is focusing on the use of *JWTs* for authorisation, I won't go into too much detail on the actual coding challenge objects themselves.  For these coding challenges, and to make a slightly more complete app, I added in a SQL database and used the `Granite-ORM` library to map the database data to objects.  I created a model titled `src/models/challenge.cr` which contained the following:

~~~ crystal
require "granite_orm/adapter/mysql"

class Challenge < Granite::ORM::Base
  adapter mysql

  field title : String
  field details : String
  field posted_by : String
  timestamps
end
~~~

I then added some samples to the database, and setup the following routes:

~~~ crystal
get "/challenges" do |env|
  challenges = Challenge.all("ORDER BY id DESC")

  render "src/challenge/views/challenges/index.ecr", "src/challenge/views/layouts/main.ecr"
end

get "/challenges/:id" do |env|
  if challenge = Challenge.find env.params.url["id"]
    render("src/challenge/views/challenges/details.ecr", "src/challenge/views/layouts/main.ecr")
  else
    "Challenge with ID #{env.params.url["id"]} Not Found"
    env.redirect "/challenges"
  end
end

get "/challenges/new" do |env|

  render "src/challenge/views/challenges/new.ecr", "src/challenge/views/layouts/main.ecr"
end
~~~

Anyone coming from a traditional web framework that includes an ORM will recognise these routes and the logic as very standard.  The **final** additions to this web app are the routes to render custom templates for authorisation and internal errors:

~~~ crystal
error 500 do
  render "src/challenge/views/error/srv.ecr", "src/challenge/views/layouts/main.ecr"
end

error 401 do
  render "src/challenge/views/error/auth.ecr", "src/challenge/views/layouts/main.ecr"
end
~~~


## Conclusion

The GitHub repo for this completed application can be [found here.](https://github.com/rbnpercy/challenge)

Coming from a lower-level programming background, whenever I am to build a web application, I always take the easiest route i.e. using a complete framework.  With Crystal being such a young language it is to be expected that the equivalent libraries from other languages do not *yet* exist.  When I build a web application, I tend to have always used Rails.  Alongside Rails, I would use Devise / Omniauth for authentication and something like Rolify or CanCan for user role management.  But with these not *yet* existing for Crystal, we have had to roll-our-own.

The above sample app is a basic, yet functional example of a Crystal-based web app that takes a user through authorisation, and role / resource management using *JWTs*.  Dropping in Auth0's hosted login on the frontend allowed us to entirely bypass having to build a User / Password system, or having to keep a *users* table altogether.

I am incredibly excited to see how the Crystal language and community will continue to grow, and I aim to continue being a part of that community too.  Maybe one day soon I'll get the time to write and maintain a modular JWT / Authentication library for Crystal that you can drop-in to your applications for instant use.

Thanks for sticking with me on what was a **long** tutorial—I greatly appreciate it!

 - @rbin