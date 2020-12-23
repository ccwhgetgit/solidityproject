import React from "react"; 
import { drizzleReactHooks} from '@drizzle/react-plugin';

const {useDrizzleState} = drizzleReactHooks; 


function LoadingContainer({children}) { 
    const drizleStatus = useDrizzleState(state => state.drizzleStatus); 
    if (drizleStatus.initialized == false){ 
        return "Loading...";
    }
    return (
        <> 
        {children}
        </>
    )
}

export default LoadingContainer; 