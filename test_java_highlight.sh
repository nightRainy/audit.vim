#!/bin/bash
# 真实测试 Java 语法高亮

echo "正在测试 Java 语法高亮..."
echo ""

# 创建测试文件
cat > /tmp/highlight_test.java << 'EOF'
public class Test {
    private String name = "hello";

    public void method() {
        int x = 42;
        // Comment
        System.out.println(name);
    }
}
EOF

echo "打开测试文件 /tmp/highlight_test.java"
echo ""
echo "在 Neovim 中你应该看到："
echo "  • public, class, void (关键字) - 有颜色"
echo "  • String, int (类型) - 有颜色"
echo "  • \"hello\" (字符串) - 有颜色"
echo "  • // Comment (注释) - 有颜色"
echo ""
echo "按任意键打开 Neovim..."
read -n 1 -s

nvim /tmp/highlight_test.java
