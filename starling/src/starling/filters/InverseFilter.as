package starling.filters
{
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Program3D;
    
    import starling.core.RenderSupport;

    public class InverseFilter extends FragmentFilter
    {
        private var mShaderProgram:Program3D;
        private var mOnes:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
        
        public function InverseFilter()
        {
            super();
        }
        
        public override function dispose():void
        {
            mShaderProgram.dispose();
            super.dispose();
        }
        
        protected override function createPrograms():void
        {
            var vertexProgramCode:String =
                "m44 op, va0, vc0 \n" + // 4x4 matrix transform to output space
                "mov v0, va1      \n"   // pass texture coordinates to fragment program
            
            var fragmentProgramCode:String =
                "tex ft0, v0, fs0 <2d, clamp, linear, mipnone>  \n" + // read texture color
                "sub ft1, fc0, ft0  \n" +   // subtract each value from '1'
                "mov ft1.w, ft0.w   \n" +   // but use original alpha value (w)
                "mov oc, ft1        \n";    // copy to output
            
            mShaderProgram = assembleAgal(vertexProgramCode, fragmentProgramCode);            
        }
        
        protected override function renderFilter(pass:int, support:RenderSupport, context:Context3D):void
        {
            // already set by super class:
            // 
            // vertex constants 0-3: mvpMatrix (3D)
            // vertex attribute 0:   vertex position (FLOAT_2)
            // vertex attribute 1:   texture coordinates (FLOAT_2)
            // texture 0:            input texture
            
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mOnes, 1);
            context.setProgram(mShaderProgram);
            drawTriangles(context);
        }
    }
}