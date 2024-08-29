# Ruby RailsGoat Spec

# SOURCES
DBTAINT
	- DBTAINT = ActiveRecord::find_by -> it looks like we have this one already?
	- DBTAINT = ActiveRecord::find -> could also be database tainted
		- LOOK IN RYAN SPECS
			- it does show up in the fblog app -> Post.find() for instance... 
		- risky function is where we list functions related to CWE
		- sources is DPA and is a whole other ballgame
		- we think the find is not working

		- compile railsgoat with latest version of ruby 

	so if a variable which is tained goes into a sink, it's tainted 
	look into Ryan's documentatino and if these are already there, don't spend too much time on it

	current user is DB tainted
	therefore, we probably consider all the properties tainted too

# Sinks
- CWE 78: OS Command Injection
	- system(TAINT, x) -> do investigation on how system can be called; is env a problem
	- system(x, TAINT)
		- LINK TO THE GITLAB THING
		-> string propagation could be an issue here
	- spawn() -> check a little more in detail 
		-> write down how it works the same in the spec as system

- CWE 352:
	In this case the application controller's 'protect_from_forgery_with' setting is commented out. This is included by default in the application controller when new Rails apps are generated, but is sometimes switched off by developers for testing purposes.  If this is done, requests will still contain authenticity tokens, but the application will not confirm their presence or validity.

	- Part 1: https://gitlab.laputa.veracode.io/research-roadmap/new-railsgoat/-/blob/fbcd8acf28a95c3761b2db86f5b634ced8c6cac5/app/controllers/application_controller.rb#L9
	
	- Part 2: https://gitlab.laputa.veracode.io/research-roadmap/new-railsgoat/-/blob/fbcd8acf28a95c3761b2db86f5b634ced8c6cac5/app/views/layouts/application.html.erb#L7
	- Part 2 as an FP: https://gitlab.laputa.veracode.io/research-roadmap/new-railsgoat/-/blob/c0c7c0658f99267658db93de2424f7a190296988/app/views/layouts/application.html.erb#L8

	From a static perspective, we want to flag if this line does not show up in the binary as we may not know whether it was commented out and discarded by the compilation process or was never present in the first place, but in either instance, a lack of presence would be cause for concern. 

	-> skip forgery protections - include this too because we should flag that if we find it https://gitlab.laputa.veracode.io/research-roadmap/new-railsgoat/-/blob/c0c7c0658f99267658db93de2424f7a190296988/app/views/layouts/application.html.erb#L8

	Any class which inherits from ActionController::Base directly and doesn't contain the protect from forgery token should be flagged 

- CWE 327:
	These are functions which we want to flag regardless of the taint.

	Digest::MD5.hexdigest 'TAINT'
	- https://gitlab.laputa.veracode.io/research-roadmap/new-railsgoat/-/blob/98a164510eb5ec014dc441a5137e6d8f3384bc54/app/models/user.rb#L45
	Digest::SHA1.hexdigest 'TAINT'
	Digest::RMD160.hexdigest 'TAINT'
	Digest::base64digest
	Digest::Class.digest 
	Digest::Class.bubblebabble
	Digest::Class.file -> we have this one already
	Digest::Class.hexdigest
	-> hexendcode in digest.rb?
	-> double check what the digest methods are here too? 



# Propagators
- CWE 80: XSS
	The raw() method outputs a given string without performing any escaping on it. The default behavior in modern Rails applications is to automatically escape tags, so this is used in cases where the developer doesn't want Rails to do so automatically. It is poor practice to call this method on any user-supplied input.
	
	ActionView::Helpers::OutputSafetyHelper - raw()
	OUT = <%= raw input %>
		- https://gitlab.laputa.veracode.io/research-roadmap/new-railsgoat/-/blob/08090870beff1892c43f956186cf4b89e3ae1bab/app/views/layouts/shared/_header.html.erb#L32

	OUT = <%= input %>
		- https://gitlab.laputa.veracode.io/research-roadmap/new-railsgoat/-/blob/08090870beff1892c43f956186cf4b89e3ae1bab/app/views/layouts/shared/_header.html.erb#L33


	In this case, the html_safe method name is misleading - it performs no escaping whatsoever and is simply an assertion that the string should be presumed safe. In fact, the raw() method is simply a wrapper around html_safe, meaning that the previously discussed lack of escaping is an issue here too.


	ActiveSupport::Core
	OUT = <%= input.html_safe %>
		- https://gitlab.laputa.veracode.io/research-roadmap/new-railsgoat/-/blob/08090870beff1892c43f956186cf4b89e3ae1bab/app/views/layouts/shared/_header.html.erb#L31

	OUT = <%= input %>
		- https://gitlab.laputa.veracode.io/research-roadmap/new-railsgoat/-/blob/08090870beff1892c43f956186cf4b89e3ae1bab/app/views/layouts/shared/_header.html.erb#L33

	Consequently, for items invoked with either the raw() or .html_safe methods, if these methods are called on a base string object or variable which is tainted, the object returned by the call on the tainted string is also tainted - Database Taint.


	Configuration 
	The configuration for escaping HTML entities in JSON is set to false: 
	ActiveSupport::JSON::Encoding::escape_html_entities_in_json = false
	This is a simple fix, simply check if the value is true.
	- https://gitlab.laputa.veracode.io/research-roadmap/new-railsgoat/-/blob/master/config/initializers/html_entities.rb#L2



All files in views if they contain a taint might be XSS
what do rails erb files do; how are they compiled, if at all?

# Web Template
Files with extentsion '.erb' under the folder '\views' are used as templates by RoR
- check RYANS DOCUMENTATION

write a very small hello world which reads string from paramters and prints it out to view 
