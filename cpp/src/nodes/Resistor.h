#pragma once

#include "Component.h"

namespace godot {

    class Resistor : public Component {
        GDCLASS(Resistor, Component)

    protected:
        static void _bind_methods() {

        }
        
    public:
        Resistor();
        ~Resistor();
        
        int a;
        int b;
        
        double resistance;
        
        void _draw() override;

        void stamp(SolverMatrix& G, std::vector<double>& rhs) override;
        void update_state(const SolverResult& result) override;
    };

}
