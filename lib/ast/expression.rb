class AST
  class Expression
    Assign = Struct.new(:name, :value) do
      def accept(visitor)
        visitor.visit_assign_expr(self)
      end
    end

    Binary = Struct.new(:left, :operator, :right) do
      def pp
        "(#{operator.lexeme} #{left.pp} #{right.pp})"
      end

      def accept(visitor)
        visitor.visit_binary_expr(self)
      end
    end

    Grouping = Struct.new(:expression) do
      def pp
        "(group #{expression.pp})"
      end

      def accept(visitor)
        visitor.visit_grouping_expr(self)
      end
    end

    Literal = Struct.new(:value) do
      def pp
        value.to_s
      end

      def accept(visitor)
        visitor.visit_literal_expr(self)
      end
    end

    Unary = Struct.new(:operator, :right) do
      def pp
        "(#{operator.lexeme} #{right.pp})"
      end

      def accept(visitor)
        visitor.visit_unary_expr(self)
      end
    end
  end
end
