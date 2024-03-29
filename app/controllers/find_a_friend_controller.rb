# frozen_string_literal: true

class FindAFriendController < ApplicationController
  before_action :logged_in?

  def get_friends_list
    render json: { friends: current_user.friends }, except: [:email]
  end

  def get_pending_friends
    render json: { pending_friends: current_user.pending_friends }, except: [:email]
  end

  def get_blocked_friends
    render json: { blocked_friends: current_user.blocked_friends }, except: [:email]
  end

  def get_requested_friends
    render json: { requested_friends: current_user.requested_friends }, except: [:email]
  end

  def find_friends
    render json: { potential_friends: find_friends_algorithm }, except: [:email]
  end

  def get_entire_friends_list
    render json: { friends: current_user.friends, pending_friends: current_user.pending_friends, blocked_friends: current_user.blocked_friends, requested_friends: current_user.requested_friends }, except: [:email]
  end

  def remove_friend
    other_user = User.find params[:id]
    current_user.remove_friend(other_user) unless other_user.nil?
  end

  def accept_friend_request
    other_user = User.find params[:id]
    current_user.accept_request(other_user) unless other_user.nil?
  end

  def send_friend_request
    user_to_friend = User.find params[:id]

    unless user_to_friend.nil?
      unless user_to_friend.id == current_user.id
        unless current_user.pending_friends.include? user_to_friend
          current_user.friend_request(user_to_friend)
        end
      end
    end

    redirect_to user_path(user_to_friend)
  end

  def block_friend
    user_to_block = User.find params[:id]

    current_user.block_friend(user_to_block) unless user_to_block.nil?
  end

  def unblock_friend
    user_to_block = User.find params[:id]

    current_user.unblock_friend(user_to_block) unless user_to_block.nil?
  end

  def set_user_location_if_required
    if current_user.location.nil?
      @ip = request.remote_ip

      unless Rails.env.production?
        @ip = Net::HTTP.get(URI.parse('http://checkip.amazonaws.com/')).squish
      end

      result = Geocoder.search(@ip)
      unless result.nil?
        @location = Location.new
        @location.latitude = result.first.latitude
        @location.longitude = result.first.longitude
        @location.country = result.first.country
        @location.city = result.first.city
        @location.state = result.first.region
        @location.zipcode = result.first.postal
        @location.user_id = current_user.id
        @location.save!

        current_user.location_id = @location.id

        current_user.save(validate: false)
      end
    end
  end

  def dashboard
    render 'find_a_friend/dashboard'
  end
end
