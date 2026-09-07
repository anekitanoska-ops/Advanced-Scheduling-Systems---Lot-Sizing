%178992 Ane Kitanoska
% Lot Sizing

% Parameter Declaration
int: Periods;
int: Items;
array[1..Items, 1..Periods] of int: Demands;
array[1..Items] of int: StockingCosts;
array[1..Items, 1..Items] of int: SetupCosts;

% Decision Variable
array[1..Periods] of var 0..Items: ProductionPlan;

%Constraints

%Production Qty Constraint
constraint
  forall (i in 1..Items)(
    sum (p in 1..Periods)(Demands[i,p]) = 
    sum (p in 1..Periods)(ProductionPlan[p] = i) 
  ); 
    
%No Backlog Constraint
constraint 
  forall (i in 1..Items)( 
    forall (p in 1..Periods)( 
      sum (q in 1..p)(Demands[i,q]) 
      <= 
      sum (q in 1..p)(ProductionPlan[q] = i)     
    ) 
  ); 

% Inventory 
array[1..Items, 1..Periods] of var 0..Periods: Inventory; 

constraint 
  forall (i in 1..Items)( 
    forall (p in 1..Periods)( 
      Inventory[i,p] = 
        sum(q in 1..p)(ProductionPlan[q] = i) 
        - 
        sum(q in 1..p)(Demands[i,q]) 
    ) 
  ); 

%Stocking Cost 
array[1..Items] of var int: StockingCostItem; 

constraint 
  forall(i in 1..Items)( 
    StockingCostItem[i] = 
      sum(p in 1..Periods)( 
        Inventory[i,p] * StockingCosts[i] 
      ) 
  ); 

%Total Stocking Cost
var int: TotalStockingCost; 

constraint 
  TotalStockingCost = 
    sum(i in 1..Items)(StockingCostItem[i]);
    
% Previous Item

array[1..Periods] of var 0..Items: PreviousItem;

constraint
  PreviousItem[1] = 0;

constraint
  forall(p in 2..Periods)(
    if ProductionPlan[p-1] != 0 then
      PreviousItem[p] = ProductionPlan[p-1]
    else
      PreviousItem[p] = PreviousItem[p-1]
    endif
  );
  
%Setup Cost
var int: TotalSetupCost; 

constraint
  TotalSetupCost =
    sum(p in 1..Periods)(
      if ProductionPlan[p] == 0 \/ PreviousItem[p] == 0 then
        0
      else
        SetupCosts[PreviousItem[p], ProductionPlan[p]]
      endif
    );
  
% Total Cost  
var int: TotalCost;

constraint
  TotalCost = TotalStockingCost + TotalSetupCost;

% Idle Periods

var int: IdlePeriods;

constraint
  IdlePeriods = sum(p in 1..Periods)(ProductionPlan[p] = 0);

%Objective Function
solve minimize TotalCost;

output [
  "Production Plan = \(ProductionPlan)\n",
  "Total Stocking Cost = \(TotalStockingCost)\n",
  "Total Setup Cost = \(TotalSetupCost)\n",
  "Total Cost = \(TotalCost)\n",
  "Idle Periods = \(IdlePeriods)\n"
];