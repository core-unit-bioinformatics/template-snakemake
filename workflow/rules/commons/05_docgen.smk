"""This module implements
a simple class to record workflow
documentation on-the-fly / in situ
with the specific purpose of
documenting config parameters and
(template) functions.

PLACEHOLDER MODULE FOR FUTURE UPDATE

"""

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
    DEVONLY = 4


class DocRecorder:

    def __init__(self):
        self.match_modname_components = re.compile("[A-Za-z0-9\.\-_]+")
        self.repository = None
        self.module_files = None
        self.module_docs = collections.OrderedDict()
        self.active_module = None
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

    def doc_new_module(self, doc_context, module_name):
        """
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
            "module_items": []
        }
        self.active_module = module_doc_name
        return

    def add_item_doc(self, doc_level, name, thing, documentation):
        """
        """
        assert isinstance(doc_level, DocLevel)
        datatype = str(type(thing))
        item_doc = ItemDoc(doc_level.value, name, datatype, documentation)
        self.module_docs[self.active_module]["module_items"].append(item_doc)
        return

    def generate_documentation(self):
        """
        """
        ordered_doc_entries = []
        for module_doc_name, module_infos in self.module_docs.items():
            for item_doc in sorted(module_infos["module_items"]):
                if module_infos["module_file"] is None:
                    mod_file = self._find_module_file(module_infos["module_path"])
                else:
                    mod_file = module_infos["module_file"]
                heapq.heappush(
                    ordered_doc_entries,
                    (
                        module_infos["module_context"].value,
                        module_doc_name,
                        mod_file,
                        item_doc.doclevel,
                        item_doc.name,
                        item_doc.datatype,
                        item_doc.documentation

                    )
                )
        _dbl = "\n\n"
        _sng = "\n"
        _indent = "    "
        out_buffer = io.StringIO()
        buffered_chars = 0
        last_context = None
        last_module = None
        last_level = None
        item_level_counter = 0
        for doc_entry in ordered_doc_entries:
            if doc_entry[0] != last_context:
                if buffered_chars > 0:
                    context_name = DocContext(last_context).name
                    out_doc_file = self.repository.joinpath(f"docs/{context_name}/params_func.md").resolve()
                    out_doc_file.parent.mkdir(exist_ok=True, parents=True)
                    with open(out_doc_file, "w") as dump:
                        dump.write(out_buffer.getvalue() + "\n")
                    out_buffer = io.StringIO()
                    buffered_chars = 0
                    last_context = None
                    last_module = None
                    last_level = None
                    item_level_counter = 0
                buffered_chars += out_buffer.write(f"# Parameter and function docs for context: {DocContext(doc_entry[0]).name}{_sng}")
                last_context = doc_entry[0]

            if doc_entry[1] != last_module:
                buffered_chars += out_buffer.write(f"{_sng}## Module: {doc_entry[1]}{_dbl}")
                last_module = doc_entry[1]

                n_chars = out_buffer.write(f"**Module file**: {doc_entry[2]}{_sng}")
                buffered_chars += n_chars

            if doc_entry[3] != last_level:
                buffered_chars += out_buffer.write(f"{_sng}### Documentation level: {DocLevel(doc_entry[3]).name}{_dbl}")
                last_level = doc_entry[3]
                item_level_counter = 1

            buffered_chars += out_buffer.write(f"{item_level_counter}. {doc_entry[4]}{_sng}")
            buffered_chars += out_buffer.write(f"{_indent}- datatype: {doc_entry[5]}{_sng}")
            buffered_chars += out_buffer.write(f"{_indent}- documentation: {doc_entry[6]}{_sng}")
            item_level_counter += 1
        if buffered_chars > 0:
            context_name = DocContext(last_context).name.lower()
            out_doc_file = self.repository.joinpath(f"docs/{context_name}/parameters.md").resolve()
            out_doc_file.parent.mkdir(exist_ok=True, parents=True)
            with open(out_doc_file, "w") as dump:
                dump.write(out_buffer.getvalue() + "\n")
        return

