import copy
import json
import threading
from typing import Any, Dict

from .base import BaseContext


class ThreadLocalContext(BaseContext):
    @property
    def _thread_local_data(self):
        if not self.__data:
            self.__data = threading.local()
            self.__data.data = {}
            self.__data.serialized_data = "{}"
        return self.__data

    def get_value(self, key: str, clear: bool = False):
        """Return value of given key if exist

        Args:
            key (str): The key which you want to retrieve
            clear (bool, optional): If `clear=True`, remove the value after it is retrieved. Defaults to False.
        """
        value = self._thread_local_data.data.get(key)
        if clear and key in self._thread_local_data.data:
            self._thread_local_data.data.pop(key)
        return value

    def _serialize_data(self):
        self._thread_local_data.serialized_data = json.dumps(self._thread_local_data.data)

    def set_value(self, key: str, value: Any) -> None:
        """Set a value into context

        Args:
            key (str): The key which you want to set
            value (Any): The value you want to set
        """
        self._thread_local_data.data[key] = value
        self._serialize_data()

    def delete_value(self, key: str) -> None:
        """Delete context value of given key

        Args:
            key (str): The key in context which you want to delete
        """
        if key in self._thread_local_data.data:
            self._thread_local_data.data.pop(key)
        self._serialize_data()

    def clean(self):
        """Clean all data in context"""
        self._thread_local_data.data = {}
        self._serialize_data()

    def get_all_values(self) -> Dict[str, Any]:
        """Get all values in context

        Returns:
            Dict[str, Any]: A dict as same as context data
        """
        return copy.copy(self._thread_local_data.data)

    def __str__(self) -> str:
        return self._thread_local_data.serialized_data
