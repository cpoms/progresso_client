require "excon"
require "excon/error"
require "json"
require "progresso/token"
require "progresso/errors"
require "active_support/core_ext/string"

module Progresso
  class Client
    def initialize(subdomain, username, password)
      @url = "https://#{subdomain}.progresso.net/v2"
      @username = username
      @password = password
    end

    %w(
      employees
      employee_contacts
      staff_absences
      employee_checks
      contacts
      learners
      learner_other_details
      learner_contacts
      learner_health
      learner_exclusions
      learner_sen_provisions
      learner_sen_major_needs
      learner_siblings
      document
      roll_call_times
      attendance_codes
      learner_roll_call_attendance
      learner_lesson_attendance
      get_photo
      udf
      udf_values
      assessment_screens
      learner_assessment_result
      learner_sats_result
      learner_assessment_cats_data
      learner_assessment_cat4_data
      learner_assessment_kS2fft_data
      learner_exam_option_result
      groups
      group_association
      school
      academic_year
      academic_terms
      term_breaks
      week_structure
      academic_calendar_events
      courses
      course_year
      subjects
      pay_scales
      tt_sources
      day_structures
      date_mappings
      day_compositions
      day_compositions_periods
      week_ranges
      tt_events
      employee_tt_events
      room_categories
      room_types
      rooms
      site
      bm_events
      bm_configuration
      bm_staff_on_behalf
      bm_assign_to
      detention_event
      bm_structure
    ).each do |resource|
      define_method resource do |options = {}|
        resource = resource.split('_').map {|w| w.capitalize}.join
        response = http_request_with_token("/#{resource}", params: options)

        content_type = response.headers["Content-Type"].match(/^(\w*\/\w*)/)[1]

        case response.status
        when 204
          []
        when 404
          { "Error" => response.body }
        when 200
          JSON.parse(response.body)
        end
      end
    end

    private
      def http_request_with_token path, options = {}
        fetch_token if !@token || @token.expired?

        options[:headers] ||= {}
        options[:headers]['Authorization'] = "Bearer #{@token.token}"

        http_get_request path, options
      end

      def fetch_token
        response = http_post_request "/Token",
          params: {
            username: @username,
            password: @password,
            grant_type: 'password'
          },
          headers: {
            'Content-Type' => 'application/x-www-form-urlencoded'
          }

        if response.status != 200
          raise InvalidCredentialsError, "Username or password incorrect"
        end

        json = JSON.parse(response.body)

        @token = Token.new(json)
      end

      def http_post_request path, options = {}
        Excon.post(
          "#{@url}#{path}",
          body: URI.encode_www_form(options[:params]),
          headers: options[:headers]
        )
      end

      def http_get_request path, options = {}
        Excon.get(
          "#{@url}#{path}?#{URI.encode_www_form(options[:params])}",
          headers: options[:headers]
        )
      end

      def handle_exceptions(body, parsed_body)
        StringIO.new(parsed_body["error"] + ", " + parsed_body["message"]) unless [200, 201].include?(body)
      end
  end
end
