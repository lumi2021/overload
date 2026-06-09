#pragma once

#include <godot_cpp/classes/node2d.hpp>
#include "../solver/solver.h"
#include <vector>

namespace godot {

    class Component : public Node2D {
        GDCLASS(Component, Node2D)


    protected:
        static void _bind_methods() {
        }

    public:
        Component();
        ~Component();

        double voltage;
        double current;
        double power;

        virtual void stamp(SolverMatrix& G, std::vector<double>& rhs);
        virtual void update_state(const SolverResult& result);
    };

}
