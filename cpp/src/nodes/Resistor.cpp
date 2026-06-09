#include "Resistor.h"

using namespace godot;


Resistor::Resistor()
{
    set_notify_transform(true);
    //queue_redraw();
}

Resistor::~Resistor()
{
}

// void Resistor::_draw()
// {
//     constexpr float step = 254.0f;
//     constexpr float halfstep = step / 2.0f;

//     Color wire(1, 1, 1);
//     Color resistor(0, 1, 0);

//     const float wire_thickness = 10.0f;
//     const float resistor_thickness = 15.0f;

//     Vector2 p1(step, 0);
//     Vector2 p2(step + halfstep, -step);
//     Vector2 p3(step + step, -step);
//     Vector2 p4(step + step, 0);
//     Vector2 p5(step + step * 2, step);
//     Vector2 p6(step + step * 2 + halfstep, 0);
//     Vector2 p7(step + step * 3, halfstep);

//     draw_line(Vector2(0, 0), Vector2(step, 0), wire, wire_thickness);

//     draw_line(p1, p2, resistor, resistor_thickness);
//     draw_line(p2, p3, resistor, resistor_thickness);
//     draw_line(p3, p4, resistor, resistor_thickness);
//     draw_line(p4, p5, resistor, resistor_thickness);
//     draw_line(p5, p6, resistor, resistor_thickness);
//     draw_line(p6, p7, resistor, resistor_thickness);

//     draw_line(p7, Vector2(step * 5, halfstep), wire, wire_thickness);
// }


void Resistor::stamp(SolverMatrix &G, std::vector<double> &rhs)
{
}

void Resistor::update_state(const SolverResult &result)
{
}
