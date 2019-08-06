# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]
  before_action :check_user, only: %i[edit destroy update_activities]

  def index
    redirect_to root_path
  end

  def update_activities
    puts 'lol'
    begin
      puts "activities params: #{update_activities_params.to_s} "
      activity = Activity.find update_activities_params.id
      current_user.activities << activity
    rescue ActiveRecord::RecordNotFound => e
      activity = nil
    end
  end

  def update_activities_params
    params.permit(:id)
  end

  def check_user
    if current_user.id.to_i != params[:id].to_i
      redirect_to root_path, notice: 'You can only edit your own user.'
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    @ip = request.remote_ip
    ipAddr = IpAddress.create([{ ip_address: @ip }])

    if ipAddr.nil?
      ipAddr = IpAddress.find_by(ip_address: @ip)
      @user.ip_address_id = ipAddr.first.id
    else
      @user.ip_address_id = ipAddr.first.id
    end

    ipAddr.first.users << @user

    unless Rails.env.production?
      @ip = Net::HTTP.get(URI.parse('http://checkip.amazonaws.com/')).squish
    end

    result = Geocoder.search(@ip)
    if result != nil    
    @location = Location.new
    @location.latitude = result.first.latitude
    @location.longitude = result.first.longitude
    @location.country = result.first.country
    @location.city = result.first.city
    @location.state = result.first.region
    @location.zipcode = result.first.postal
    @location.save!

    @user.location_id = @location.id

    end

    respond_to do |format|
      if @user.save
        @location.user_id = @user.id
        format.html { redirect_to login_path, notice: 'User was successfully created. Please login now.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
      @user = User.find(params[:id])    
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :race, :gender, :religion, :sexuality, :about_me, :first_name, :last_name, :birthdate)
  end
end
