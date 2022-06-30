#!/usr/bin/env python

from __future__ import print_function

from pddlstream.algorithms.meta import solve, create_parser
from pddlstream.language.constants import PDDLProblem, Or, print_solution
from pddlstream.algorithms.search import solve_from_pddl

import sys
import os
import json
import glob
cwd = os.path.dirname(os.path.realpath(__file__))



def parse(dataset_dir):
    domain_pddl = ""
    problem_pddl = ""
    expert_json = None 

    with open(os.path.join(cwd, "PutTaskExtended_domain.pddl")) as f:
        domain_pddl = f.read()
        domain_pddl = domain_pddl.replace("totalCost", "total-cost")

    with open(os.path.join(cwd, "temp.csv"), 'w') as outfile:
        for trial in glob.glob(f"{dataset_dir}/*/*"):
            experiment_name = os.path.basename(os.path.dirname(trial))
            trial_name = os.path.basename(trial)

            with open(os.path.join(trial, "problem_0.pddl")) as f:
                problem_pddl = f.read()
                problem_pddl = problem_pddl.replace("(:metric minimize (totalCost))\n", "")
                problem_pddl = problem_pddl.replace("totalCost", "total-cost")

            with open(os.path.join(trial, "traj_data.json")) as f:
                expert_json = json.load(f)


if __name__ == '__main__':
    dataset_dir = sys.argv[1]
    parse(dataset_dir)
