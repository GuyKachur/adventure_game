#include <stdio.h>
#include <stdlib.h>

enum directions {forward = 1, right, backward, left,}; //this way we can use all the directions as numersls 1 2 3 4.(good for going the opposite, or checking it and being like, i went one. next time ust go one without checking
//alternatiley we could just declare them as constants and deal with em that way.

typedef struct {
  int *stack;
  int size;
  int top;
} STACK;

void initialize_stack(STACK *s, int initialSize ) {
s-> stack = (int *) malloc(initialSize * sizeof(int));
s->size = initialSize;
s->top = 0;
}

void push_to_stack (STACK *s, int data) {
if (s->top == s->size) {
    s->size *= 2;
    s->stack = (int *) realloc(s->stack, s->size * sizeof(int));
}
s->stack[s->top++] = data;
}


int peek (STACK *s) {
return s->top;

}

int empty (STACK *s) {
if (s->top == -1) {return 1;}
else {return 0;
}
}


int pop_stack (STACK *s) {
    int data;
    if(empty(s)) {
        printf("This stack is empty foo. \n");
    }
    else {
        data = s->top;
        printf("%d\n", data);
        s->top -= 1;
        return data;
    }

}
//so pop stack does some odd things, in that it works seemingly correnctly but then it returns a kind of odd number instead of what it should for data, but it changes the top correctly.
//and seems to access things correctly.

//
//
////we need the robot to move forward till it changes ir reading
//
//void go_robot_go()
//{
//    //first robot moves forwad till ir is not on black.
//    (while IRSENSOR == BLACK)
//          {
//    forward();
//          }
//          //now the robot has moved forward the loop breaks but hte robot is still moving forward.
//          stopmotors();
//          (while IRSENSOR == WHITE)
//          {
//              backward();
//              stop();
//              }
//              //now the robot has moved backwards and stopped, on the corner of the black tape.
//
//
//}
//
//// FUNCTION LIST
//as long as both a bac sensor and a forward sensor are the same, move forward.
//stop if the front sensor is different then the back sensor.
//
//
//
//
////gets to corner and needs to pick a path.
//
//
////
////turn right,
////push that ot stack
////move forward and check vaidity
////if valid keep going (keep adding to stack)
////    if not then return, pop the og decision off the stack, make the direction loop start at whatever one youre already at. if the option was three, turn right, and add one,.. so four!
////
////
////
//
//
//while ir sensor is black, keep going forward.
//when its not black turn right and keep going
//
//void drive_until_corner() {
//while (FRONTIRSENSOR == BACKIRSENSOR) {forward();}
//
//}
//
//drive_until_corner();
//turnright(); push_to_stack(&s, RIGHT)
//drive_until_corner();
//
//
//
//void deadend() {
//int counter = 0;
//if(FS != BS) {
//    turnright();
//    counter++;
//}
//
//}
//
//
//
//
////so whenveer i pick a path i should just record that number into the stack
//
//
//
//
//get to corner
//then turn right, push 1 to stack, continue.
//int whereimgoing;
//
//if (pop(stack) == 4) //deadend
//{
//
//}
//
//
//
//
//
//
//
//int choose_direction_for_unexplored(int left, int right, int front)
//{
//    int paths[] = {0,0,0,0};
//    int possible_paths = 0;
//
//    if (front == 0) {
//        paths[possible_paths] = FORWARD;
//        possible_paths++;
//    }
//
//    if (left == 0) {
//        paths[possible_paths] = TURN_LEFT;
//        possible_paths++;
//    }
//
//    if (right == 0) {
//        paths[possible_paths] = TURN_RIGHT;
//    }
//
//    if (right == 1 && left == 1 && front == 1) {
//        return BACKWARDS;
//    } else if (right == 0 && left == 0 && front ==0) {
//        return STOP;
//    }
//
//
//    return paths[0];
//}
//
//
//












void main() {

STACK s;
int i;

initialize_stack(&s, 5);  // initially 5 elements
for (i = 0; i < 100; i++)
  push_to_stack(&s, i);  // automatically resizes as necessary
printf("%d\n", s.stack[9]);  // print 10th element
printf("%d\n", s.top);  // print number of elements
printf("%d\n", pop_stack(&s));
printf("%d\n", s.stack[s.top-1]);
printf("%d\n", s.top);  // print number of elements
printf("%d\n", peek(&s));
}
