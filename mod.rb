require 'open-uri'


def make_piece(piece_code)
	case piece_code
		when 'i'
			return [[1],[1],[1],[1]]
		when 'j'
			return [[0,1],[0,1],[1,1]]
		when 'l'
			return [[1,0],[1,0],[1,1]]
		when 'o'
			return [[1,1],[1,1]]
		when 's'
			return [[0,1,1],[1,1,0]]
		when 't'
			return [[1,1,1],[0,1,0]]
		when 'z'
			return [[1,1,0],[0,1,1]]
	end
end

def rotate_degree(piece,degree)
	while degree > 0
		piece = rotate piece
		degree -= 90
	end
	return piece
end

def rotate(piece)
	return piece.transpose.collect {|row| row.reverse}
end

def place(piece, piece_code, pos, board)
	endgame unless check piece, pos, 0, board

	top = 0
	20.times do |top|
		break if !check piece, pos, top, board
	end
	board = insert piece, piece_code, pos, top, board
	return board
end

def insert(piece, piece_code, pos, top, board)
	piece.each_with_index do |y,i|
		y.each_with_index do |x,j|
			board[i + top][j + pos] = piece_code if x == 1
		end
	end
	return board
end

def check(piece, pos, top, board)
	height = piece.length
	return false if top + height >= 20
	good = true
	piece.each_with_index do |y,i|
		y.each_with_index do |x,j|
			good = false if x == 1 and board[i + top + 1][j + pos] != '.'
		end
	end
	return good
end

def init_board
	board = []
	20.times do |i|
		board[i] = [];
		10.times do |j|
			board[i][j] = '.'
		end
	end
	return board
end

def print_board(board)
	board.each do |row|
		row.each do |cell|
			print cell
		end
		print "\n"
	end
end

def collapse_board(board)
	board.reverse.each_with_index do |row,i|
		row = row.to_s
		if row =~ /^[^.]+$/
			$score += 10
			board.delete_at(19-i)
			board.insert 0, %w(. . . . . . . . . .)
			board = collapse_board board
			break
		end
	end
	return board
end

def endgame
	#puts "Final Score: #{$score}"
	#puts "Total Moves: #{$moves}"
	print $score
	exit
end

def go
	bot_url = ARGV[0]

	board = init_board

	pieces = %w(i j l o s t z)

	$score = 0
	$moves = 0

	while true
		piece_code = pieces[rand pieces.length]
		sep = bot_url =~ /\?/ ? '&' : '?'
		url = "#{bot_url}#{sep}piece=#{piece_code}&board=#{board.collect{|row| row.to_s}.join '%20'}"
		response =  open(url).read
		response = response.split('&').collect{|pair| pair.split('=')[1].to_i}
		position = response[0]
		rotation = response[1]

		piece = make_piece piece_code
		piece = rotate_degree piece, rotation
	
		$moves += 1
		board = place piece, piece_code, position, board

		#print_board board
		board = collapse_board board
	end
end

go
