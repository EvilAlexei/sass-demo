SassDataInfo = provider()

def _sass_binaries_impl(ctx):
  """
  Perform a global compilation of all .scss files with a single invocation of
  the Sass compiler.
  """

  root = ctx.attr.srcs[0].label.package + "/"
  inputs = depset([f for t in ctx.attr.srcs for f in t.files])
  outputs = [ctx.actions.declare_file(
    f.basename.replace(".scss", ".css"),
    sibling = f,
  ) for f in inputs]

  args = ctx.actions.args()
  args.add("--no-source-map")
  args.add([root + ":" + ctx.bin_dir.path + '/' + root])
  args.add("--load-path", root)

  ctx.actions.run(
    inputs = inputs,
    outputs = outputs,
    executable = ctx.executable._compiler,
    arguments = [args],
    mnemonic = "CompileSass",
    progress_message = "Compiling Sass stylesheets",
  )

  return [DefaultInfo(files=depset(outputs))]

sass_binaries = rule(
  implementation = _sass_binaries_impl,
  attrs = {
    "srcs": attr.label_list(
      allow_files = [".scss"],
      allow_empty = False,
    ),
    "_compiler": attr.label(
      default = Label("@npm//node_modules/sass:sass__bin"),
      executable = True,
      cfg = "target",
    ),
  },
)
