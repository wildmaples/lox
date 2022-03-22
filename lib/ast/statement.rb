class AST
  class Statement
    Block = Struct.new(:statements) do
      def accept(visitor)
        visitor.visit_block_stmt(self)
      end
    end

    Expression = Struct.new(:expression) do
      def accept(visitor)
        visitor.visit_expression_stmt(self)
      end
    end

    Print = Struct.new(:expression) do
      def accept(visitor)
        visitor.visit_print_stmt(self)
      end
    end

    Var = Struct.new(:name, :initializer) do
      def accept(visitor)
        visitor.visit_var_stmt(self)
      end
    end

    Variable = Struct.new(:name) do
      def accept(visitor)
        visitor.visit_variable_stmt(self)
      end
    end
  end
end
