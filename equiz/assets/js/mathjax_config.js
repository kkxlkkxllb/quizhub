
   window.MathJax = {
      tex2jax: {
        inlineMath: [['$', '$'], ["\\(", "\\)"]],
        processEscapes: true,
        showProcessingMessages: false
      },
      "CHTML-preview": {
        disabled: true
      },
      MathMenu: {
      styles: {
        ".MathJax_Menu": {"z-index":2001}
      }
      },
      AuthorInit: function () {
        MathJax.Hub.Register.StartupHook("MathMenu Ready",function () {MathJax.Menu.BGSTYLE["z-index"] = 2000;});
      }
    }

