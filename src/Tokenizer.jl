path = string(pwd(), "\\src\\FirstTest.txt")

const TokenTypeDict = Dict{String, Int64}("LEFT_PAREN" => 1, "RIGHT_PAREN" => 2, "LEFT_BRACE" => 3,
            "RIGHT_BRACE" => 4, "COMMA" => 5, "DOT" => 6, "MINUS" => 7, "PLUS" => 8,
            "SEMICOLON" => 9, "COLON" => 10, "SLASH" => 11, "STAR" => 12, "BANG" => 13,
            "BANG_EQUAL" => 14, "EQUAL" => 15, "EQUAL_EQUAL" => 16, "GREATER" => 17,
            "GREATER_EQUAL" => 18, "LESS" => 19, "LESS_EQUAL" => 20,

            #Literals
            "IDENTIFIER" => 21, "STRING" => 22, "NUMBER" => 23, "UNIT" => 24,

            #KeyWords of Vehicle
            "VEHICLE" => 25, "DRYMASS" => 26, "FUELMASS" => 27, "REFERENCEAREA" => 28,
            "REFERENCELENGTHLON" => 29, "REFERENCELENGTHLAT" => 30, "REFLECTIONCOEFF" => 31,
            "SRPAREA" => 32, "INERTIATENSOR" => 33, "INVINERTIATENSOR" => 34,
            #ACTUATORS, MISSIONSYSTEM, GUIDANCESYSTEM, CONTROLSYSTEM, NAVIGATIONSYSTEM,
            #INITIALSTATE,

            #KeyWords of SolarSystem
            "SOLARSYTEM" => 35, "BARYCENTER" => 36, "STAR" => 37, "PARENT" => 38,
            "MASS" => 39, "RADIUS" => 40, "LUMINOUSITY" => 41, "STATE" => 42,
            "PLANETMOONBARYCENTER" => 43, "PLANET" => 44, "ALBEDO" => 45, "ATMOSPHERE" => 46,
            "GRAVITY" => 47, "SHAPE" => 48, "MOON" => 49,

            #End of File
            "EOF" => 50)

#Create TokenType structure, which also checks if the potential Token actually exists
struct TokenType
 token::String

 #Inner constructor
 function TokenType(tokenin::String)
    if haskey(TokenTypeDict, tokenin)
        return new(tokenin)
    else
        error("Unrecognized token type occured!")
    end
 end #constructor
end #TokenType

#Create Token structure
struct Token
    token::TokenType
    lexeme::String
    literal::String
    line::Int64

    #Make constructor
    function Token(token::String , lexeme::String, literal::String, line::Int64)
        newtoken = TokenType(token)
        return new(newtoken, lexeme, literal, line)
    end  #Constructor
end #Token

#Construct Tokenizer Type with help function
mutable struct Tokenizer
    source::String
    start::Int64
    current::Int64
    line::Int64
    isAtEnd::Function
    peek::Function
    peeknext::Function
    advance::Function
    match::Function
    addToken1::Function
    addToken2::Function
    scanToken::Function
    tokenize::Function
    tokens::Vector{Token}

    #Constructor
    function Tokenizer(path::String)
        this = new()
        #set source
        this.source = readstring(path)

        #initialise current and line integers
        this.start = 1
        this.current = 1
        this.line = 1
        this.tokens = Vector{Token}()

        #make isAtEnd function
        this.isAtEnd = function ()
            return this.current >= length(this.source)
        end #isAtEnd

        #make peek function
        this.peek = function ()
            if this.isAtEnd()
                return '\0'
            else
                return this.source[this.current]
            end
        end #peek

        #make peeknext function
        this.peeknext = function ()

        end #peeknext

        #make advance function
        this.advance = function ()
            this.current += 1
            return this.source[this.current - 1]
        end #advance

        #make match function
        this.match = function (expected::Char)
            if this.isAtEnd() || (this.source[this.current] != expected )
                return false
            else
                this.current += 1
                return true
            end
        end #match

        #make addToken functions
        this.addToken1 = function (token::String)
            this.addToken2(token, "null")
        end #addToken

        this.addToken2 = function (token::String, literal::String)
            text = this.source[this.start:this.current-1]
            push!(this.tokens, Token(token, text, literal, this.line))
        end

        #make ScanToken function
        this.scanToken = function ()
            c = this.advance()
            #use if loop, because switch cases dont exist in base Julia(?!)
            if c == '('
                this.addToken1("LEFT_PAREN")
            elseif c == ')'
                this.addToken1("RIGHT_PAREN")
            elseif c == '{'
                this.addToken1("LEFT_BRACE")
            elseif c == '}'
                this.addToken1("RIGHT_BRACE")
            elseif c == ','
                this.addToken1("COMMA")
            elseif c == '.'
                this.addToken1("DOT")
            elseif c == '-'
                this.addToken1("MINUS")
            elseif c == '+'
                this.addToken1("PLUS")
            elseif c == ';'
                this.addToken1("SEMICOLON")
            elseif c == ':'
                this.addToken1("COLON")
            elseif c == '*'
                this.addToken1("STAR")
            elseif c == '!'
                this.match('=') ? this.addToken1("BANG_EQUAL") : this.addToken1("BANG")
            elseif c == '='
                this.match('=') ? this.addToken1("EQUAL_EQUAL") : this.addToken1("EQUAL")
            elseif c == '<'
                this.match('=') ? this.addToken1("LESS_EQUAL") : this.addToken1("LESS")
            elseif c == '>'
                this.match('=') ? this.addToken1("GREATER_EQUAL") : this.addToken1("GREATER")
            elseif c == '/'
                if this.match('/') #this is a comment then, untill end of line
                    while this.peek() != '\n' && !this.isAtEnd()
                        this.advance()
                    end
                else
                    this.addToken("SLASH")
                end
            elseif c == ' '
                nothing
            elseif c == '\r'
                nothing
            elseif c == '\t'
                nothing
            elseif c == '\n'
                this.line += 1
            else
                error("Unidentified Token Found in line $(this.line), column $(this.current)")
            end

        end #scanToken

        this.tokenize = function()
            while !this.isAtEnd()
                #start with next lexeme
                this.start = this.current
                this.scanToken()
            end

            #Add EOF token to the end of the list
            push!(this.tokens,Token("EOF", "", "null", this.line))
            return nothing
        end #tokenize

        return this
    end #Constructor
end# Tokenizer
