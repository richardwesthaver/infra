export PY_HEPTAPOD=`$PYTHON -c "import heptapod, os; print(os.path.dirname(heptapod.__file__))"`
echo $PY_HEPTAPOD
