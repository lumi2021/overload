#include <vector>

class SolverMatrix
{
public:
    int rows;
    int cols;

    std::vector<double> data;

    double& operator()(int r, int c)
    {
        return data[r * cols + c];
    }
};