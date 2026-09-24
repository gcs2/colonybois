"""Original connected implicit maquette, NumPy only.

Smooth-union signed-distance anatomy -> marching tetrahedra -> indexed GLB.
Not a replacement for authored sculpting/retopology. No image generation.
"""
import json, math, struct, time
from pathlib import Path
import numpy as np

OUT=Path(__file__).resolve().parent
STEP=.035
AXES=[np.arange(-2.25,2.251,STEP,dtype=np.float32),
      np.arange(-.4,3.601,STEP,dtype=np.float32),
      np.arange(-1.4,1.751,STEP,dtype=np.float32)]
X,Y,Z=np.meshgrid(*AXES,indexing='ij')

def ellipsoid(center, radii):
    q=[(a-c)/r for a,c,r in zip((X,Y,Z),center,radii)]
    k0=np.sqrt(sum(a*a for a in q))
    k1=np.sqrt(sum((a/r)**2 for a,r in zip(q,radii)))
    return (k0*(k0-1)/np.maximum(k1,.0001)).astype(np.float32)

def union(a,b,k=.15):
    h=np.clip(.5+.5*(b-a)/k,0,1)
    return b+(a-b)*h-k*h*(1-h)

def capsule(a,b,ra,rb=None):
    rb=ra if rb is None else rb
    pa=[grid-c for grid,c in zip((X,Y,Z),a)]
    ba=np.asarray(b)-a
    t=np.clip(sum(v*c for v,c in zip(pa,ba))/sum(ba*ba),0,1)
    d=np.sqrt(sum((v-t*c)**2 for v,c in zip(pa,ba)))
    return d-(ra+(rb-ra)*t)

def curve(points,radii,subdiv=5):
    """Catmull-Rom sampled tapered capsules; smooth joined, not tube objects."""
    pts=np.asarray(points,dtype=np.float32)
    result=np.full(X.shape,100,np.float32)
    samples=[]; rs=[]
    for i in range(len(pts)-1):
        p0,p1,p2,p3=pts[max(i-1,0)],pts[i],pts[i+1],pts[min(i+2,len(pts)-1)]
        for t in np.linspace(0,1,subdiv,endpoint=False):
            samples.append(.5*((2*p1)+(-p0+p2)*t+(2*p0-5*p1+4*p2-p3)*t*t+(-p0+3*p1-3*p2+p3)*t*t*t))
            rs.append(radii[i]*(1-t)+radii[i+1]*t)
    samples.append(pts[-1]); rs.append(radii[-1])
    for a,b,ra,rb in zip(samples[:-1],samples[1:],rs[:-1],rs[1:]):
        result=np.minimum(result,capsule(a,b,ra,rb))
    return result

def sculpt():
    # Mantle is a fleshy low dome with an overhanging cut-away underside.
    head=ellipsoid((0,2.67,-.06),(1.5,.68,1.02))
    hollow=ellipsoid((0,1.99,.65),(1.08,.57,.77))
    head=np.maximum(head,-hollow)
    rolled=curve([(-1.26,2.43,.63),(-.70,2.39,.91),(0,2.43,1.02),(.67,2.35,.91),(1.28,2.41,.59)],
                 [.14,.16,.17,.15,.14])
    result=union(head,rolled,.13)
    # Thick stalk roots grow out of the same skin surface, unequal poses.
    for s in [-1,1]:
        lift=.11 if s<0 else -.05
        stalk=curve([(s*1.11,2.62,.22),(s*1.44,2.62+lift,.44),(s*1.73,2.64+lift,.68)],
                    [.35,.285,.255])
        result=union(result,stalk,.25)
    # Mantle, hanging throat, shoulders and belly all share one mesh surface.
    body=ellipsoid((0,.94,-.04),(1.14,1.25,.79))
    belly=ellipsoid((0,.71,.36),(1.00,.84,.62))
    body=union(body,belly,.26)
    throat=ellipsoid((0,1.97,.12),(.74,.69,.54))
    body=union(body,throat,.31)
    for s in [-1,1]:
        body=union(body,ellipsoid((s*.81,1.35,-.03),(.59,.63,.65)),.22)
    result=union(result,body,.25)
    # Connected flesh ridges frame the recessed beak. They blend into chest.
    for s in [-1,1]:
        for i in range(3):
            x=.22+.23*i
            ridge=curve([(s*x,2.4,.71),(s*x*.97,2.0,.78),(s*x*.97,1.60,.77),(s*(.29+.1*i),1.17,.61)],
                        [.11,.12,.11,.045],subdiv=4)
            result=union(result,ridge,.035)
    arms=[
      ([(-.83,1.42,0),(-1.30,.9,.28),(-1.50,.54,.63),(-1.53,.84,1.0),(-1.44,1.48,1.03),(-1.21,1.68,.98),(-1.06,1.49,1.0)],
       [.38,.34,.30,.26,.195,.115,.04]),
      ([(.87,1.43,.03),(1.25,1.08,.38),(1.32,.58,.71),(.96,.30,1.00),(.47,.41,1.18),(.31,.77,1.16),(.51,.97,1.11),(.72,.87,1.12),(.70,.68,1.14)],
       [.39,.35,.33,.29,.235,.20,.15,.10,.035]),
      ([(-.55,.62,.7),(-.82,.81,1.15),(-.82,1.19,1.21),(-1.00,1.37,1.07)],
       [.23,.19,.14,.04])]
    for points,radii in arms:
        result=union(result,curve(points,radii),.14)
    # Very gentle anatomical skin undulation, no noise hiding silhouette.
    result+=.006*np.sin(X*7.2+Y*1.1)*np.sin(Z*8.1-Y*2.3)
    return result.astype(np.float32)

def polygonize(field):
    # Six tetrahedra per cell share a consistent body diagonal.
    corners=np.array([[0,0,0],[1,0,0],[1,1,0],[0,1,0],[0,0,1],[1,0,1],[1,1,1],[0,1,1]])
    tets=[[0,5,1,6],[0,1,2,6],[0,2,3,6],[0,3,7,6],[0,7,4,6],[0,4,5,6]]
    edges=[(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]
    dims=np.array(field.shape)-1
    values=[field[c[0]:c[0]+dims[0],c[1]:c[1]+dims[1],c[2]:c[2]+dims[2]].reshape(-1) for c in corners]
    faces=[]
    for tet in tets:
        vals=np.stack([values[c] for c in tet],axis=1)
        codes=np.sum((vals<0)*(1<<np.arange(4)),axis=1)
        for code in range(1,15):
            ids=np.flatnonzero(codes==code)
            if not len(ids):continue
            base=np.stack(np.unravel_index(ids,dims),axis=1).astype(np.float32)
            inside=[i for i in range(4) if code&(1<<i)]
            outside=[i for i in range(4) if not code&(1<<i)]
            # Order a triangle or quad around the crossing boundary.
            if len(inside)==1:
                e=[(inside[0],j) for j in outside]; triangles=[(0,1,2)]
            elif len(outside)==1:
                e=[(outside[0],j) for j in inside]; triangles=[(0,1,2)]
            else:
                a,b=inside; c,d=outside
                e=[(a,c),(a,d),(b,d),(b,c)]; triangles=[(0,1,2),(0,2,3)]
            verts=[]
            for a,b in e:
                av,bv=vals[ids,a].astype(np.float64),vals[ids,b].astype(np.float64)
                t=av/(av-bv)
                coord=base+corners[tet[a]]+(corners[tet[b]]-corners[tet[a]])*t[:,None]
                verts.append(coord*STEP+np.array([a[0] for a in AXES]))
            for tri in triangles:
                faces.append(np.stack([verts[i] for i in tri],axis=1))
    triangles=np.concatenate(faces).astype(np.float32)
    flat=triangles.reshape(-1,3)
    _,unique,inverse=np.unique(np.round(flat,6),axis=0,return_index=True,return_inverse=True)
    vertices=flat[unique]
    indices=inverse.reshape(-1,3)
    # SDF gradient is a smooth normal. Correct winding for glTF CCW.
    grad=np.gradient(field,STEP)
    coords=(vertices-np.array([a[0] for a in AXES]))/STEP
    low=np.floor(coords).astype(int); frac=coords-low
    normals=np.zeros_like(vertices)
    for offset in corners:
        ix=np.clip(low+offset,0,np.array(field.shape)-1)
        weight=np.prod(np.where(offset,frac,1-frac),axis=1)
        normals+=np.stack([g[ix[:,0],ix[:,1],ix[:,2]] for g in grad],axis=1)*weight[:,None]
    normals/=np.maximum(np.linalg.norm(normals,axis=1)[:,None],1e-8)
    face_normal=np.cross(vertices[indices[:,1]]-vertices[indices[:,0]],vertices[indices[:,2]]-vertices[indices[:,0]])
    bad=np.sum(face_normal*np.mean(normals[indices],axis=1),axis=1)<0
    indices[bad]=indices[bad][:,[0,2,1]]
    keep=(indices[:,0]!=indices[:,1]) & (indices[:,1]!=indices[:,2]) & (indices[:,2]!=indices[:,0])
    indices=indices[keep]
    return vertices,normals,indices.astype(np.uint32)

def colors(vertices):
    x,y,z=vertices.T
    grain=(np.sin(x*12+y*4)*np.sin(y*9-z*6)+np.sin(x*23-z*11)*.3)*.012
    color=np.broadcast_to(np.array([.45,.335,.47]),(len(vertices),3)).copy()
    color+=grain[:,None]
    # Soft ochre feeding veil, constrained to the inner throat.
    front=np.clip((z-.52)/.23,0,1)
    inset=np.clip((.40-np.abs(x))/.20,0,1)
    height=np.clip((2.45-y)/.2,0,1)*np.clip((y-1.25)/.2,0,1)
    veil=(front*inset*height*.85)[:,None]
    color=color*(1-veil)+np.array([.55,.42,.27])*veil
    # Restrained mottling in continuous 3D coordinates, no UV seams.
    pattern=np.sin(x*14.7+np.cos(z*7))*np.sin(z*16.1+y*5.6)*np.cos(y*13.0-x*3)
    spots=np.clip((pattern-.69)*4,0,.5)[:,None]
    color=color*(1-spots)+np.array([.47,.55,.49])*spots
    return np.clip(color,0,1).astype(np.float32)

def write_glb(vertices,normals,indices,color):
    arrays=[vertices.astype('<f4'),normals.astype('<f4'),indices.reshape(-1).astype('<u4'),color.astype('<f4')]
    buffer=b'';views=[];access=[]
    for i,a in enumerate(arrays):
        offset=len(buffer); raw=a.tobytes();buffer+=raw
        buffer+=b'\x00'*((-len(buffer))%4)
        views.append({'buffer':0,'byteOffset':offset,'byteLength':len(raw),'target':34963 if i==2 else 34962})
        ac={'bufferView':i,'componentType':5125 if i==2 else 5126,'count':len(a),'type':'SCALAR' if i==2 else 'VEC3'}
        if i==0:ac.update(min=a.min(axis=0).tolist(),max=a.max(axis=0).tolist())
        access.append(ac)
    doc={'asset':{'version':'2.0','generator':'Original NumPy implicit sculpt / Frontier Worlds'},
      'scene':0,'scenes':[{'nodes':[0]}],'nodes':[{'name':'Connected_merchant_anatomy','mesh':0}],
      'meshes':[{'name':'Smooth_union_sculpt','primitives':[{'attributes':{'POSITION':0,'NORMAL':1,'COLOR_0':3},'indices':2,'material':0}]}],
      'materials':[{'name':'Matte_lavender_vertex_pigment','pbrMetallicRoughness':{'baseColorFactor':[1,1,1,1],'metallicFactor':0,'roughnessFactor':.76}}],
      'buffers':[{'byteLength':len(buffer)}],'bufferViews':views,'accessors':access}
    raw=json.dumps(doc,separators=(',',':')).encode();raw+=b' '*((-len(raw))%4)
    glb=struct.pack('<III',0x46546c67,2,12+8+len(raw)+8+len(buffer))+struct.pack('<II',len(raw),0x4e4f534a)+raw+struct.pack('<II',len(buffer),0x004e4942)+buffer
    (OUT/'connected_anatomy.glb').write_bytes(glb)
    # Topology is measured rather than inferred from a single mesh node.
    parent=np.arange(len(vertices),dtype=np.int32)
    def find(i):
        while parent[i]!=i:
            parent[i]=parent[parent[i]]; i=parent[i]
        return i
    for a,b,c in indices:
        pa,pb,pc=find(a),find(b),find(c)
        parent[pb]=pa; parent[pc]=pa
    referenced=np.unique(indices)
    component_count=len(set(find(i) for i in referenced))
    edges=np.sort(np.concatenate((indices[:,[0,1]],indices[:,[1,2]],indices[:,[2,0]])),axis=1)
    _,edge_counts=np.unique(edges,axis=0,return_counts=True)
    stats={'grid_step_m':STEP,'grid_shape':list(X.shape),'vertices':len(vertices),'triangles':len(indices),'bounds':[vertices.min(axis=0).tolist(),vertices.max(axis=0).tolist()],
           'connected_geometry':component_count==1,'connected_components':component_count,'boundary_edges':int(np.sum(edge_counts==1)),
           'nonmanifold_edges':int(np.sum(edge_counts>2)),'unused_vertices':len(vertices)-len(referenced),
           'rigged':False,'retopologized':False,'production_ready':False,'color_source':'3D vertex pigment; no UV texture','method':'Smooth union signed distances, marching tetrahedra, gradient normals'}
    (OUT/'sculpt_stats.json').write_text(json.dumps(stats,indent=2))
    print(json.dumps(stats))

if __name__=='__main__':
    start=time.time(); print('Sculpting fused anatomy...',flush=True)
    field=sculpt(); print('Polygonizing...',flush=True)
    vertices,normals,indices=polygonize(field)
    write_glb(vertices,normals,indices,colors(vertices))
    print(f'Finished in {time.time()-start:.1f}s',flush=True)



