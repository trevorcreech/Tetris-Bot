#!/usr/bin/ruby

VARS = %w(wall_below piece_below wall_on_left piece_on_left wall_on_right piece_on_right space_filled blank_space_below)

TRIALS = 3

def score(candidate)
	options = {}
	VARS.each_with_index do |var,i|
		options[var] = candidate[i]
	end
	query_string = options.collect{|pair| pair.join('=')}.join('&')
	score = 0
	TRIALS.times do |i|
		score += `ruby mod.rb http://localhost/tetris/bot.php?#{query_string}`.to_i
	end
	score /= TRIALS
	return score
end

def random_candidate
	a = []
	range = 10
	VARS.length.times {|i| a.push((rand(range) - range/2).to_f)}
	return a
end

def merge(mother, father)
	#puts "Merging #{mother} and #{father}."
	child = []
	VARS.length.times do |i|
		child .push((mother[i] + father[i]) / 2)
	end
	#Random mutation
	#child[rand VARS.length] += (rand(6) - 3)
	child = child.collect{|var| var += (rand(3) - 1)}

	#puts "#{child}"
	return child
end

def test(candidate)
	total = 0
	10.times do |i|
		score = score candidate
		total += score
		puts "#{score}"
	end
	puts "#{total / 10}"
end

def go
	mother = random_candidate
	father = random_candidate
	child = []
	generation = 0
	start = Time.now.to_f
	while true
		new1 = []
		new1score = -1
		new2 = []
		new2score = -1
		scores = []
		puts "---------------"
		puts "Generation #{generation}"
		generation += 1
		10.times do |i|
			child = merge(mother,father)
			child_score = score child
			scores << child_score
			puts "Child's score is #{child_score}."
			if child_score > new1score or new1score == -1
				new2 = new1
				new2score = new1score
				new1 = child
				new1score = child_score
				#puts "New1 bumped"
			elsif child_score > new2score or new2score == -1
				new2 = child
				new2score = child_score
				#puts "New2 bumped"
			end
		end
		mother = new1
		father = new2
		puts mother.join(' ')
		puts "Average: #{scores.inject(0){|sum,score| sum + score}/scores.length}"
	end
	puts child
	puts "#{Time.now.to_f - start} seconds."
end

test [1,1,1,1,1,1,7,-6]
