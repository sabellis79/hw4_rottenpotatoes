require 'spec_helper'

describe MoviesController do
  describe 'edit page for appropriate Movie' do
    it 'When I goto "Find Movies With Same Director", I should be on the Movies By Director page for the Movie' do
      mock = mock('Movie')
      mock.stub!(:director).and_return('director name')
      
      movies = [mock('Movie'), mock('Movie')]
      
      Movie.should_receive(:find).with('99').and_return(mock)
      Movie.should_receive(:find_all_by_director).with(mock.director).and_return(movies)
      get :director, {:id => '99'}
      response.should render_template('movies/director')
    end
    it 'should redirect to index page if movie does not have a director' do
      mock = mock('Movie')
      mock.stub!(:director).and_return(nil)
      mock.stub!(:title).and_return(nil)
      
      Movie.should_receive(:find).with('99').and_return(mock)
      get :director, {:id => '99'}
      response.should redirect_to(movies_path)
    end
  end
end
