# frozen_string_literal: true

Date::DATE_FORMATS[:header] = proc { |date| date.format_like('Tue 19 Jul') }
Date::DATE_FORMATS[:hour] = proc { |date| date.format_like('5 PM') }
