classdef GraphBipartite < matlab.mixin.Copyable
    %GRAPHBIPARTITE Bipartite graph class definition
    %   Detailed explanation goes here
    
    properties
        equationArray = Equation.empty; % Array with equations contained in the graph
        variableArray = Variable.empty; % Array with viariables contained in the graph
        adjacency = Adjacency.empty; % Adjacency object
        coords = [];
    end
    
    properties (Dependent)
        numVars
        numEqs
    end
    
    properties (SetAccess = private)
        variableAliasArray = {};
        equationAliasArray = {};
        equationIdArray = [];
        variableIdArray = [];
        adjacencyUndir = []; % Undirected copy of the adjacency matrix
        adjacencyCtrl = []; % The controlability adjacency matrix
        adjacencyObsrv = []; % The observability adjacency matrix
        ph % Plot handle
    end
    
    properties (Hidden = true)
        debug = false;
%         debug = true;
        constructing = false;
    end
    
    
    methods
        
        %%
        function obj = GraphBipartite(model,coords)
            % Constructor
            
            obj.constructing = true; % Begin construction
            % Read model file and store related equations and variables
            groupsNum = size(model,1); % Number of equation groups in model
            for groupIndex=1:groupsNum % For each group
                group = model{groupIndex,1};
                grEqNum = size(group,1);
                grPrefix = model{groupIndex,2};
                grEqAliases = cell(1,grEqNum); % Create unique equation aliases
                for i=1:grEqNum
                    grEqAliases{i} = sprintf('eq%d',i);
                end
                for i=1:grEqNum
                    tempEquation = Equation([],group{i,1},grEqAliases{i},grPrefix);
                    obj.equationArray(end+1) = tempEquation;
                end
            end
            
            obj.updateEquationAliasArray();
            obj.updateEquationIdArray();
            obj.updateVariableArray();
            obj.createAdjacency();
            
            % Store external nodes coordinates input
            if nargin>=2
                obj.coords = coords;
            end
            
            obj.constructing = false; % End construction
        end
        
        %%
        function set.variableArray(obj,value)
        % Set the VariableArray property and update the VariableAliaArray property
            obj.variableArray = value;
            if ~obj.constructing
                obj.updateVariableAliasArray(); % Update the variable aliases array
            end
        end
        
        %%
        function updateVariableArray(obj)
        % Re-build the variableArray from the contents of equationArray
            obj.constructing = true;
            obj.variableArray = Variable.empty;
            obj.variableAliasArray = cell(0,0);
            for i=1:length(obj.equationArray) % For each equation
                for j=1:length(obj.equationArray(i).variableArray) % For each variable
                    alias = obj.equationArray(i).variableArray(j).alias;
                    index = find(strcmp(obj.variableAliasArray,alias));
                    if isempty(index) % This variable is not stored yet
                        obj.variableArray(end+1) = obj.equationArray(i).variableArray(j).copy(); % Modify variable objects only via their equation array
                        obj.variableAliasArray{end+1} = alias;
                        obj.variableIdArray(end+1) = obj.equationArray(i).variableArray(j).id;
                        if obj.debug fprintf('GRA: Parsed new variable %s\n',alias); end
                    else
                        % We are not interested in merging is* properties.
                        % This wouldn't make sense.
                        if obj.debug fprintf('GRA: Already have variable %s stored\n',alias); end
                    end
                end
            end
            obj.constructing = false;
            if obj.debug fprintf('variableArray length = %d\n',length(obj.variableArray)); end;
        end
        
        %%
        function updateVariableAliasArray(obj)
        % Update the array holding the variable objects
            obj.variableAliasArray = cell(size(obj.variableArray));
            for i=1:length(obj.variableAliasArray)
                obj.variableAliasArray{i} = obj.variableArray(i).alias;
            end
        end
        
        %%
        function set.equationArray(obj,value)
        % Set the equationArray property and update the equationAliasArray property
            obj.equationArray = value;
            if ~obj.constructing
                obj.updateEquationAliasArray(); % Update the variable aliases array
            end
        end
        
        %%
        function updateEquationAliasArray(obj)
        % Update the array holding the equation objects aliases
            obj.equationAliasArray = cell(size(obj.equationArray));
            for i=1:length(obj.equationAliasArray)
                obj.equationAliasArray{i} = [obj.equationArray(i).prefix obj.equationArray(i).alias];
            end
        end
        
        %%
        function updateEquationIdArray(obj)
        % Update the array holding the equation objects IDs
            obj.equationIdArray = zeros(size(obj.equationArray));
            for i=1:length(obj.equationIdArray)
                obj.equationIdArray(i) = obj.equationArray(i).id;
            end
        end        
        
        %%
        function createAdjacency(obj)
        % Create the graph adjacency matrix
            numVars = obj.numVars;
            numEqs = obj.numEqs;
            numEls = numVars + numEqs;
            adjacency = zeros(numEls,numEls);
            for i=1:length(obj.equationArray)
                for j=1:length(obj.variableArray)
                    varId = obj.variableIdArray(j);
                    index = find(obj.equationArray(i).variableIdArray==varId); % Check if variable is contained in this equation
                    if obj.debug fprintf('GRA: (%d,%d) Found %d instance(s) of %s in %s\n',i,j,length(index), obj.variableArray(j).prAlias,obj.equationArray(i).prAlias); end
                    if ~isempty(index) % If yes, fill the corresponding cells accordingly
                        % General case
                        adjacency(numVars+i,j) = 1; % From equation to variable
                        adjacency(j,numVars+i) = 1; % From variable to equation
                        if obj.equationArray(i).variableArray(index).isKnown % TODO specify mutually exclusive properties
                            % No operation
                        end
                        if obj.equationArray(i).variableArray(index).isMeasured
                            % No operation
                        end
                        if obj.equationArray(i).variableArray(index).isInput
                            adjacency(numVars+i,j) = 0; % From equation to variable
                        end
                        if obj.equationArray(i).variableArray(index).isOutput
                            % No operation
                        end
                        if obj.equationArray(i).variableArray(index).isMatched
                            adjacency(j,numVars+i) = 0; % From variable to equation
                        end
                        if obj.equationArray(i).variableArray(index).isDerivative
                            % No operation, unless causality says otherwise
                        end
                        if obj.equationArray(i).variableArray(index).isIntegral
                            % No operation, unless causality says otherwise
                        end
                        if obj.equationArray(i).variableArray(index).isNonSolvable
                            adjacency(numVars+i,j) = 0; % From equation to variable
                        end
                    end
                end
            end
            
            obj.adjacency(end+1) = Adjacency(adjacency,obj.equationAliasArray,obj.variableAliasArray);
            
        end
        
        %%
        function plotG4M(obj)
            % Plot graph using Graphviz4Matlab library
            
            gray = [0.3 0.3 0.3];
            yellow = [1.0 1.0 0.0];
            blue = [0.0 0.2 1.0];
            
            numVars = length(obj.variableArray);
            numCons = length(obj.equationArray);
            numEls = numVars + numCons;
            
            nodeLabels = [obj.variableAliasArray obj.equationAliasArray];
            
            % Colour nodes
            nodeColors = zeros(numEls,3);
            for i=1:numVars
                nodeColors(i,:) = yellow;
                if obj.variableArray(i).isInput
                    nodeColors(i,:) = gray;
                end
            end
            for i=(numVars+1):numEls
                nodeColors(i,:) = blue;
            end
            
            % disp(size(adjacency));
            % disp(size(nodeLabels));
            
            obj.ph = drawNetwork(obj.adjacency.BD, '-nodeLabels', nodeLabels, '-nodeColors', nodeColors);
            
            if (~isempty(obj.coords))
                obj.ph.setNodePositions(obj.coords);
            end
            
            for i=(numVars+1):numEls % Make constraints square
                obj.ph.nodeArray(i).curvature = [0,0];
            end
            
            % TODO: Colour matched nodes
            
            obj.ph.tightenAxes;
            diameter = max([obj.ph.nodeArray(:).width]); % Place nodes on grid
            aspectRatio = 14/9;
            
            obj.coords = obj.ph.getNodePositions();
            
            obj.coords = obj.coords*(1-aspectRatio*diameter);
            obj.coords(:,1) = obj.coords(:,1)*(1-aspectRatio*diameter); % Correcting for tight display bug
            obj.coords = obj.coords+0.5*aspectRatio*diameter;
            obj.ph.setNodePositions(obj.coords);
            obj.ph.increaseFontSize;
            obj.ph.increaseFontSize;
            
        end
        
        %%
        function res = get.numVars(obj)
            res = length(obj.variableArray);
        end
        
        %%
        function res = get.numEqs(obj)
            res = length(obj.equationArray);
        end
        
    end
    
end
