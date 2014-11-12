class StaticPagesController < ApplicationController
  require 'git_loader'

  def home
    @content = ''
  end

  def update
    GitLoader.load
    flash[:notice] = 'loaded'
    flash[:danger] = GitLoader.get_hash_for_file('config.ru')
  end
end
