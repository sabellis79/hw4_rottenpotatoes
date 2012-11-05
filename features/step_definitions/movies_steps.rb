#require 'cucumber_screenshot'

# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|

  Movie.delete_all
  
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.

	if(!Movie.exists?(movie))	
		Movie.create(movie);
	end
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.

  match = /#{e1}.*#{e2}/m =~ page.body

  assert match, "#{e2} was found after #{e1}"

end

#Then /I should be on the Similar Movies page for "(.*)"/ do |title|
#  assert page.has_content?('Similar Movies to ' + title)
#end

# Make sure we only have movies with the specified ratings displayed in the table
Then /I expect to see the only movies with the checked ratings/ do

	# Get movies from HTML table
	rows = find("table#movies//tbody").all('tr//td[1]')
	actual_movies = rows.map { |r| r.text }

	@unchecked_ratings ||= {} # created in a previous step	
	
	if(@unchecked_ratings != {})
		# movies with selected ratings only
		expectedMovies = Movie.where("rating not in (?)", @unchecked_ratings).map{|movie| movie.title}
	else
		# all movies
		expectedMovies = Movie.all().map{|movie| movie.title}
	end
	
	assert actual_movies.sort == expectedMovies.sort
end

Then /^the director of "(.*)" should be "(.*)$/ do |title, director|
	movie = Movie.where(:title => title).first
	assert movie.director = director
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb

  ratings = rating_list.split(",").map{|r| r.strip}
  
  if(uncheck == "un")
	ratings.each do|rating|
		puts "unchecking " + rating
		step %{I uncheck "ratings_#{rating}"}
	end

	# keep a list of ratings we have un-checked
	@unchecked_ratings = ratings
  else
	ratings.each do|rating|
		puts "checking " + rating
		step %{I check "ratings_#{rating}"}
	end
  end
end
