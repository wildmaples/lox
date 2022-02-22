class AST
  class Expression
    Binary = Struct.new(:left, :operator, :right) do
      def pp
        "(#{operator.lexeme} #{left.pp} #{right.pp})"
      end
    end

    Grouping = Struct.new(:expression) do
      def pp
        "(group #{expression.pp})"
      end
    end

    Literal = Struct.new(:value) do
      def pp
        value.to_s
      end
    end

    Unary = Struct.new(:operator, :right) do
      def pp
        "(#{operator.lexeme} #{right.pp})"
      end
    end
  end
end
