"""This module implements
a simple class to record workflow
documentation on-the-fly / in situ
with the specific purpose of
documenting config parameters,
(template) functions, and class
instances that implement a certain
functionality.
"""

import collections
import enum
import heapq
import io
import pathlib


class DocContext(enum.Enum):
    TEMPLATE = 1
    WORKFLOW = 2


class DocLevel(enum.Enum):
    USERCONFIG = 1
    GLOBALVAR = 2
    GLOBALFUN = 3
    GLOBALOBJ = 4
    OBJMETHOD = 5
    DEVONLY = 6


MemberDoc = collections.namedtuple("MemberDoc", "doclevel name datatype documentation")


OrderedMemberDoc = collections.namedtuple(
    "OrderedMemberDoc", [
        "modcontext", "modname", "modfile",
        "memberlevel", "membername", "memberdtype",
        "documentation"
    ]
)


class DocRecorder:

    def __init__(self):
        self.match_modname_components = re.compile("[A-Za-z0-9\.\-_]+")
        self.repository = None
        self.module_files = None
        self.module_docs = dict()
        self.active_module = None

        # the following members only exist
        # to create encapsulated contexts for
        # shorter functions when generating the docs
        self._docgen_buffer = io.StringIO()
        self._docgen_charbuf = 0
        self._docgen_last_context = None
        self._docgen_last_module = None
        self._docgen_last_level = None
        self._docgen_member_level_counter = 0

        # some hardcoded string constants
        # to simplify Markdown generation
        self._single_line_break = "\n"
        self._double_line_break = "\n\n"
        self._four_spaces_indent = "    "

        return

    def _collect_module_files(self):

        smk_files = set(self.repository.glob("**/*.smk"))
        snake_files = set(self.repository.glob("**/*.snakefile"))
        self.module_files = sorted(smk_files.union(snake_files))
        assert self.module_files
        return

    def _find_module_file(self, module_path):

        if self.repository is None:
            current_globals = dict(globals())
            if "DIR_REPOSITORY" in current_globals:
                self.repository = current_globals["DIR_REPOSITORY"]
                self._collect_module_files()
        if self.repository is None:
            module_file = None
        else:
            module_file = [
                modfile for modfile in self.module_files
                if str(modfile).endswith(module_path)
            ]
            if len(module_file) != 1:
                raise ValueError(f"No module file for path: {module_path}")
            module_file = module_file[0].relative_to(self.repository)
        return module_file

    def _docgen_reset(self):
        """
        """
        self._docgen_buffer = io.StringIO()
        self._docgen_charbuf = 0
        self._docgen_last_context = None
        self._docgen_last_module = None
        self._docgen_last_level = None
        self._docgen_member_level_counter = 0
        return

    def add_module_doc(self, doc_context, module_name):
        """
        This member function must be called at the beginning
        of each new module to record the documentation
        in the correct module file context.

        Args:
            doc_context (DocContext): documentation context enum type
            module_name (str or list of str): name of the module given as relative path

        Returns:
            None
        """
        assert isinstance(doc_context, DocContext)
        if isinstance(module_name, list) or isinstance(module_name, tuple):
            name_components = module_name
        else:
            assert isinstance(module_name, str)
            name_components = []
            for mobj in self.match_modname_components.finditer(module_name):
                start, end = mobj.span()
                name_component = module_name[start:end]
                name_components.append(name_component)

        module_doc_name = "::".join(name_components)
        module_path_string = "/".join(name_components)
        self.module_docs[module_doc_name] = {
            "module_name": module_doc_name,
            "module_path": module_path_string,
            "module_file": self._find_module_file(module_path_string),  # may be None
            "module_context": doc_context,
            "module_members": []
        }
        self.active_module = module_doc_name
        return

    def add_member_doc(self, doc_level, name, thing, documentation):
        """
        This function of the DocRecorder class / DOCREC instance
        must be called to document module-level members, i.e. global
        variables, functions, objects, user configurables and
        developer-only information.

        Args:
            doc_level (DocLevel): the documentation level
            name (str): name of the documented thing
            thing (any): the documented thing (i.e., some Python object)
            documentation (str): the documentation for thing

        Returns:
            None

        Raises:
            ValueError: if doc_level in [DocLevel.OBJMETHOD, DocLevel.GLOBALFUN]
        """
        assert isinstance(doc_level, DocLevel)
        if doc_level in [DocLevel.OBJMETHOD, DocLevel.GLOBALFUN]:
            err_msg = (
                "Doc error: use DOCREC.add_function_doc(...) to "
                "document class methods or global function: "
                f"{doc_level.name} - {name} - {documentation}"
            )
            raise ValueError(err_msg)
        datatype = str(type(thing))
        member_doc = MemberDoc(doc_level.value, name, datatype, documentation)
        self.module_docs[self.active_module]["module_members"].append(member_doc)
        return

    def add_function_doc(self, function, parent=None):
        """
        This function of the DocRecorder class / DOCREC instance
        must be called to document either module-level / global
        functions or class methods. In case of class methods,
        the documentation level is set to DocLevel.OBJMETHOD and to
        DocLevel.GLOBALFUN otherwise.

        Args:
            function (callable): function/method to document
            parent (None or class): parent class if class method

        Returns:
            None
        """
        datatype = str(type(function))
        if parent is not None:
            parent_type = str(type(parent))
            doc_level = DocLevel.OBJMETHOD
            datatype = f"{parent_type}.{datatype}"
        else:
            doc_level = DocLevel.GLOBALFUN
        docstring = f"\n```{function.__doc__}\n```"  # embed in Markdown code block
        member_doc = MemberDoc(doc_level.value, function.__name__, datatype, docstring)
        self.module_docs[self.active_module]["module_members"].append(member_doc)
        return

    def generate_documentation(self):
        """
        """
        ordered_doc_entries = []
        for module_doc_name, module_infos in self.module_docs.items():
            for member_doc in sorted(module_infos["module_members"]):
                if module_infos["module_file"] is None:
                    mod_file = self._find_module_file(module_infos["module_path"])
                else:
                    mod_file = module_infos["module_file"]
                heapq.heappush(
                    ordered_doc_entries,
                    OrderedMemberDoc(
                        module_infos["module_context"].value,
                        module_doc_name, mod_file,
                        member_doc.doclevel, member_doc.name,
                        member_doc.datatype,
                        member_doc.documentation
                    )
                )
        # shorthands...
        _dbl = self._double_line_break
        _sng = self._single_line_break
        _indent = self._four_spaces_indent

        for doc_entry in ordered_doc_entries:
            if doc_entry.modcontext != self._docgen_last_context:
                if self._docgen_charbuf > 0:
                    context_name = DocContext(self._docgen_last_context).name
                    out_doc_file = self.repository.joinpath(f"docs/{context_name}/autodoc.md").resolve()
                    out_doc_file.parent.mkdir(exist_ok=True, parents=True)
                    with open(out_doc_file, "w") as dump:
                        dump.write(self._docgen_buffer.getvalue() + "\n")
                    self._docgen_reset()

                self._docgen_charbuf += self._docgen_buffer.write(
                    f"# Parameter and function docs for context: {DocContext(doc_entry.modcontext).name}{_sng}"
                )
                self._docgen_last_context = doc_entry[0]

            if doc_entry.modname != self._docgen_last_module:
                self._docgen_charbuf += self._docgen_buffer.write(f"{_sng}## Module: {doc_entry.modname}{_dbl}")
                self._docgen_last_module = doc_entry.modname

                n_chars = self._docgen_buffer.write(f"**Module file**: {doc_entry[2]}{_sng}")
                self._docgen_charbuf += n_chars

            if doc_entry.memberlevel != self._docgen_last_level:
                self._docgen_charbuf += self._docgen_buffer.write(
                    f"{_sng}### Documentation level: {DocLevel(doc_entry.memberlevel).name}{_dbl}")
                self._docgen_last_level = doc_entry.memberlevel
                self._docgen_member_level_counter = 1

            self._docgen_charbuf += self._docgen_buffer.write(
                f"{self._docgen_member_level_counter}. {doc_entry.membername}{_sng}"
            )
            self._docgen_charbuf += self._docgen_buffer.write(
                f"{_indent}- datatype: {doc_entry.memberdtype}{_sng}"
            )
            self._docgen_charbuf += self._docgen_buffer.write(
                f"{_indent}- documentation: {doc_entry.documentation}{_sng}"
            )
            self._docgen_member_level_counter += 1

        if self._docgen_charbuf > 0:
            context_name = DocContext(self._docgen_last_context).name.lower()
            out_doc_file = self.repository.joinpath(f"docs/{context_name}/autodoc.md").resolve()
            out_doc_file.parent.mkdir(exist_ok=True, parents=True)
            with open(out_doc_file, "w") as dump:
                dump.write(self._docgen_buffer.getvalue() + "\n")
        return


DOC_RECORDER = DocRecorder()

DOCREC = DOC_RECORDER

# now use the DocRecorder object as intended
# and document it using itself.
# NB here: setting '_THIS_MODULE' and
# '_THIS_CONTEXT' should normally happen
# at the top of the module, which cannot
# be done here because the DocContext enum
# had to be specified first.

_THIS_MODULE = ["commons", "05_docgen.smk"]
_THIS_CONTEXT = DocContext.TEMPLATE

DOCREC.add_module_doc(_THIS_CONTEXT, _THIS_MODULE)

DOCREC.add_member_doc(
    DocLevel.GLOBALOBJ,
    "DocContext",
    DocContext,
    (
        "Enum listing the different documentation contexts, "
        "which is currently limited to TEMPLATE and WORKFLOW. "
        "The context is used to sort the dumped documentation "
        "Markdown file into 'docs/template' or 'docs/workflow'."
    )
)

DOCREC.add_member_doc(
    DocLevel.GLOBALOBJ,
    "DocLevel",
    DocLevel,
    (
        "Enum listing the different documentation levels "
        "such as USERCONFIG and GLOBALVAR that need to be "
        "specified when documenting module 'members'. "
        "See documentation of the DOC_RECORDER object "
        "for more details."
    )
)

DOCREC.add_member_doc(
    DocLevel.GLOBALOBJ,
    "DOC_RECORDER",
    DOC_RECORDER,
    (
        "Instance of the `DocRecorder` class that is globally "
        "available to record documentation *in place*. "
        "The DocRecorder class has three member functions to "
        "record documentation about 'objects' (in the Python sense) "
        "in module contexts. At the beginning of each module, "
        "call the function `DOC_RECORDER.add_module_doc(...)` "
        "to start a new module context. After that, call the "
        "functions `DOC_RECORDER.add_member_doc(...)` for each "
        "member (everything except for functions/methods) of "
        "the module that you want to document. For functions "
        "and object methods, call `DOC_RECORDER.add_function_doc(...)`. "
        "The documentation is dumped as a Markdown file and "
        "thus supports (basic) Markdown syntax for emphasis etc. "
        "In order to generate the documentation, execute the "
        "workflow with the target rule `run_build_docs`."
    )
)

DOCREC.add_member_doc(
    DocLevel.GLOBALOBJ,
    "DOCREC",
    DOC_RECORDER,
    (
        "Alias/short hand for DOC_RECORDER."
    )
)

DOCREC.add_function_doc(
    DOCREC.add_module_doc,
    DOCREC
)

DOCREC.add_function_doc(
    DOCREC.add_member_doc,
    DOCREC
)

DOCREC.add_function_doc(
    DOCREC.add_function_doc,
    DOCREC
)
