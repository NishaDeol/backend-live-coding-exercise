require "pstore" # https://github.com/ruby/pstore

STORE_NAME = "tendable.pstore"
store = PStore.new(STORE_NAME)

QUESTIONS = {
  "q1" => "Can you code in Ruby?",
  "q2" => "Can you code in JavaScript?",
  "q3" => "Can you code in Swift?",
  "q4" => "Can you code in Java?",
  "q5" => "Can you code in C#?"
}.freeze

class Survey
  def initialize
    @store = PStore.new("survey_results.pstore")
    @questions = QUESTIONS
    @ratings = []
    @average_rating = 0.0
  end

  def run
    show_welcome_message

    loop do
      run_survey
      calculate_and_print_rating
      calculate_and_print_average_rating
      break unless ask_to_continue?
    end

    show_exit_message
  end

  private

  def show_welcome_message
    puts "Welcome to the Survey!"
    puts "Answer each question with 'Yes' or 'No'."
  end

  def run_survey
    answers = []
    @questions.each do |question|
      answer = ask_question(question)
      answers << answer
    end
    save_answers(answers)
  end

  def ask_question(question)
    print "#{question} (Yes/No): "
    answer = gets.chomp.downcase
    until valid_answer?(answer)
      print "Please enter 'Yes' or 'No': "
      answer = gets.chomp.downcase
    end
    answer
  end

  def valid_answer?(answer)
    ["yes", "no", "y", "n"].include?(answer)
  end

  def save_answers(answers)
    @store.transaction do
      @store[:answers] ||= []
      @store[:answers] << answers
    end
  end

  def calculate_and_print_rating
    total_questions = @questions.size
    total_yes_answers = count_yes_answers

    rating = (total_yes_answers.to_f / total_questions) * 100

    puts "\nRating for this run: #{rating.round(2)}%"
    @ratings << rating
  end

  def count_yes_answers
    total_yes = 0
    @store.transaction(true) do
      @store[:answers].last.each do |answer|
        total_yes += 1 if ["yes", "y"].include?(answer)
      end
    end
    total_yes
  end

  def calculate_and_print_average_rating
    @average_rating = @ratings.sum / @ratings.size.to_f
    puts "Average rating so far: #{@average_rating}%"
  end

  def ask_to_continue?
    print "\nWould you like to continue? (Yes/No): "
    answer = gets.chomp.downcase
    until ["yes", "no", "y", "n"].include?(answer)
      print "Please enter 'Yes' or 'No': "
      answer = gets.chomp.downcase
    end
    answer == "yes" || answer == "y"
  end

  def show_exit_message
    puts "\nThank you for participating in the Survey!"
  end
end

# Run the survey
survey = Survey.new
survey.run
