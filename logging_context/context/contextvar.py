import contextvars
import json
from typing import Any, Dict

from .base import BaseContext


class ContextVarsContext(BaseContext):
    serializer = json.dumps

    def __init__(self) -> None:
        self._var = contextvars.ContextVar("logging_context", default={})
        self._serialized_data = "{}"

    def get_value(self, key: str) -> Any:
        data = self._var.get(default={})
        return data.get(key)

    def get_all_values(self) -> Dict[str, Any]:
        return self._var.get(default={})

    def set_value(self, key: str, value: Any) -> None:
        context_value = self._var.get(default={})
        context_value[key] = value
        self._var.set(context_value)
        self._serialized_data = json.dumps(context_value)

    def delete_value(self, key: str) -> None:
        context_value = self._var.get(default={})
        if key in context_value:
            context_value.pop(key)
        self._var.set(context_value)
        self._serialized_data = json.dumps(context_value)

    def clean(self):
        self._var.set({})

    def __str__(self) -> str:
        return self._serialized_data
