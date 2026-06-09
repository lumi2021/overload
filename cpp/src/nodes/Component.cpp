#include "Component.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

Component::Component() {
	voltage = 0.0;
	current = 0.0;
	power = 0.0;
}

Component::~Component() {
}

void godot::Component::stamp(SolverMatrix &G, std::vector<double> &rhs)
{
}

void godot::Component::update_state(const SolverResult &result)
{
}
